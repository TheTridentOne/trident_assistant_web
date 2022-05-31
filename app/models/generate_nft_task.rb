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

  before_validation :setup_royalty

  validates :royalty, numericality: { in: 0..0.10 }
  validates :raw, presence: true

  def process!
    return unless pending?

    download_and_unzip

    FileUtils.cd File.join unzipped_dir, raw.filename.to_s.split('.').first

    succeeded = []
    failed = []

    Dir.glob('./metadata/*.json').each do |meta|
      basename = File.basename meta, '.json'
      meta =
        begin
          JSON.parse File.read(meta)
        rescue StandardError
          {}
        end
      next if meta.blank?

      image = File.join '.', 'assets', meta['image']
      next unless File.exist? image

      item = collection.items.find_by identifier: basename.to_i.to_s
      next if item.present?

      item = collection.items.new identifier: basename.to_i.to_s

      item.icon.attach io: File.open(image), filename: basename
      item.media.attach io: File.open(image), filename: basename

      media_hash = SHA3::Digest::SHA256.hexdigest(File.read(image))
      token = {
        id: basename.to_i.to_s,
        name: meta['name'],
        description: meta['description'],
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

      meta['attributes'].each do |trait|
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
        name: meta['name'],
        description: meta['description'],
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
  end

  def download_and_unzip
    Zip::File.open(temp_file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join unzipped_dir, f.name
        FileUtils.mkdir_p File.dirname(f_path)
        f.extract f_path unless File.exist?(f_path)
      end
    end
  end

  def temp_file
    file = File.join unzipped_dir, 'raw.zip'
    return file if File.exist? file

    File.write file, URI.parse(raw.url).open.read, encoding: 'ascii-8bit'
    file
  rescue StandardError
    FileUtils.rm file, force: true
  end

  def unzipped_dir
    dir = Rails.root.join('tmp', raw.key)
    Dir.mkdir dir unless Dir.exist? dir
    dir
  end

  private

  def setup_royalty
    self.royalty = 0.0 if royalty.blank?
  end
end
