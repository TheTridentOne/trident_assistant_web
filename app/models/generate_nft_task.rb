# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id            :uuid             not null, primary key
#  params        :jsonb
#  processed_at  :datetime
#  result        :jsonb
#  state         :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :uuid
#  token_id      :uuid
#  user_id       :uuid
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#
class GenerateNftTask < Task
  store_accessor :params, %i[royalty]

  has_one_attached :raw
  has_one_attached :metadata
  has_one_attached :assets

  before_validation :setup_royalty

  validates :royalty, numericality: { in: 0..0.10 }
  validates :metadata, presence: true

  def process!
    return unless pending?

    start_process!

    download_and_unzip_metadata
    download_and_unzip_assets

    succeeded = []
    failed = []

    json_files.each do |json|
      basename = File.basename json, '.json'

      json =
        begin
          JSON.parse File.read(json)
        rescue StandardError => e
          failed.push({ basename.to_i.to_s => e.inspect })
          {}
        end
      next if json.blank?

      item = collection.items.find_by identifier: basename.to_i.to_s
      if item.present?
        failed.push({ basename.to_i.to_s => 'Already existed' })
        next
      end

      image_path =
        if URI::DEFAULT_PARSER.make_regexp.match(json['image'])
          json['image']
        elsif collection.find_attachment_by_filename(json['image'])
          collection.find_attachment_by_filename(json['image']).url
        else
          png_files_manifest[json['image']]
        end
      if image_path.blank?
        failed.push({ basename.to_i.to_s => "Cannot find image: #{json['image']}" })
        next
      end

      task = collection.tasks.new(
        type: 'CreateItemTask',
        user_id: user_id,
        source_task_id: id,
        identifier: basename.to_i.to_s,
        royalty: royalty,
        image_path: image_path,
        json: json
      )

      if task.save
        succeeded.push({ basename.to_i.to_s => task.id })
      else
        failed.push({ basename.to_i.to_s => task.errors.full_messages.join(';') })
      end
    end

    update result: { succeeded: succeeded, failed: failed }
    finish!
  ensure
    pend! if processing?
  end

  def download_and_unzip_metadata
    return if metadata_temp_file.blank?

    Zip::File.open(metadata_temp_file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join unzipped_dir, f.name
        FileUtils.mkdir_p File.dirname(f_path)
        next if File.exist?(f_path)

        f.extract f_path
      end
    end
  end

  def download_and_unzip_assets
    return if assets_temp_file.blank?

    Zip::File.open(assets_temp_file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join unzipped_dir, f.name
        FileUtils.mkdir_p File.dirname(f_path)
        next if File.exist?(f_path)

        f.extract f_path
      end
    end
  end

  def metadata_temp_file
    return if metadata.url.blank?

    file = File.join unzipped_dir, 'metadata.zip'
    return file if File.exist? file

    File.write file, URI.parse(metadata.url).open.read, encoding: 'ascii-8bit'
    file
  rescue StandardError
    FileUtils.rm file, force: true
    nil
  end

  def assets_temp_file
    return if assets.url.blank?

    file = File.join unzipped_dir, 'assets.zip'
    return file if File.exist? file

    File.write file, URI.parse(assets.url).open.read, encoding: 'ascii-8bit'
    file
  rescue StandardError
    FileUtils.rm file, force: true
    nil
  end

  def unzipped_dir
    dir =
      if ENV['EXTERNAL_DATA_DIR'].present?
        File.join ENV['EXTERNAL_DATA_DIR'], id
      else
        Rails.root.join('tmp', id)
      end
    FileUtils.mkdir_p dir
    dir
  end

  def json_files
    Dir.glob "#{unzipped_dir}/**/*.json"
  end

  def png_files
    Dir.glob "#{unzipped_dir}/**/*.png"
  end

  def png_files_manifest
    manifest = {}
    png_files.each do |file|
      manifest[File.basename(file)] = file
    end

    manifest
  end

  private

  def setup_royalty
    self.royalty = 0.0 if royalty.blank?
  end
end
