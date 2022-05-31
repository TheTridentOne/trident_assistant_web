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

    FileUtils.cd unzipped_dir

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

      image =
        if URI::DEFAULT_PARSER.make_regexp.match(json['image'])
          begin
            URI.parse(json['image']).open
          rescue OpenURI::HTTPError
            nil
          end
        else
          png_files_manifest[json['image']].presence && File.open(png_files_manifest[json['image']])
        end
      if image.nil?
        failed.push({ basename.to_i.to_s => "Cannot find image: #{json['image']}" })
        next
      end

      item = collection.items.find_by identifier: basename.to_i.to_s
      next if item.present?

      item = collection.items.new identifier: basename.to_i.to_s

      item.icon.attach io: image, filename: basename
      item.media.attach io: image, filename: basename

      media_hash = SHA3::Digest::SHA256.hexdigest(image.read)
      token = {
        id: basename.to_i.to_s,
        name: json['name'],
        description: json['description'],
        icon: {
          url: item.media.url
        },
        media: {
          url: item.media.url,
          hash: media_hash
        }
      }
      checksum = {
        fields: ['creator.id', 'creator.royalty', 'collection.id', 'collection.name',
                 'collection.split', 'token.id', 'token.name', 'token.media.hash'],
        algorithm: 'sha256'
      }

      (json['attributes'] || []).each do |trait|
        next if trait['trait_type'].blank? || trait['value'].blank?

        token[:attributes] ||= {}
        token[:attributes][trait['trait_type']] = trait['value']
        checksum[:fields].push "token.attributes.#{trait['trait_type']}"
      end

      metadata = TridentAssistant::Utils::Metadata.new(
        creator: {
          id: user.id,
          name: user.name,
          royalty: royalty.to_f.round(2).to_s
        },
        collection: {
          id: collection.id,
          name: collection.name,
          description: collection.description,
          split: collection.split.round(2).to_s,
          icon: {
            url: collection.icon_url
          }
        },
        token: token,
        checksum: checksum
      )

      item.assign_attributes(
        name: json['name'],
        royalty: royalty,
        description: json['description'],
        metadata: metadata.json,
        metahash: SHA3::Digest::SHA256.hexdigest(metadata.checksum_content)
      )

      if item.save
        succeeded.push item.identifier
      else
        failed
          .push(
            {
              identifier: item.identifier,
              errors: item.errors.full_messages.join(';')
            }
          )
      end
    end

    update result: { succeeded: succeeded, failed: failed }
    finish!
    assets&.purge_later
    metadata&.purge_later
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
    dir = Rails.root.join('tmp', id)
    Dir.mkdir dir unless Dir.exist? dir
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
