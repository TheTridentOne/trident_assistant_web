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
class CreateItemTask < Task
  store_accessor :params, %i[source_task_id royalty identifier image_path json]

  before_validation :setup_royalty

  validates :royalty, numericality: { in: 0..0.10 }
  validates :identifier, presence: true
  validates :image_path, presence: true
  validates :json, presence: true

  def process!
    return unless pending?

    start_process!

    item = collection.items.find_by identifier: identifier
    if item.present?
      update result: { identifier => 'already existed' }
      fail!
      return
    end

    image_url = image_path if URI::DEFAULT_PARSER.make_regexp.match(image_path)
    img =
      if URI::DEFAULT_PARSER.make_regexp.match(image_path)
        begin
          URI.parse(image_path).open
        rescue OpenURI::HTTPError
          nil
        end
      else
        File.open image_path
      end

    if img.nil?
      update result: { identifier => "Cannot open image: #{json['image']}" }
      fail!
      return
    end

    blob = ActiveStorage::Blob.find_by key: image_url.split('/').last

    item = collection.items.new identifier: identifier
    if image_url.blank?
      item.icon.attach io: img, filename: identifier
    elsif blob.present?
      item.icon.attach blob.signed_id
    end

    media_hash = SHA3::Digest::SHA256.hexdigest(img.read)
    token = {
      id: identifier,
      name: json['name'],
      description: json['description'],
      icon: {
        url: image_url || item.icon.url
      },
      media: {
        url: image_url || item.icon.url,
        hash: media_hash
      }
    }
    checksum = {
      fields: ['creator.id', 'creator.royalty', 'collection.id', 'collection.name',
               'collection.split', 'token.id', 'token.name', 'token.media.hash'],
      algorithm: 'sha256'
    }

    (json['attributes'].presence || []).each do |trait|
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
        split: collection.split.round(4).to_s,
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
      update result: { identifier: item.identifier, metahash: item.metahash }
      finish!
    else
      update result: { identifier: item.identifier, errors: item.errors.full_messages.join(';') }
      fail!
    end
  ensure
    pend! if processing?
  end

  private

  def setup_royalty
    self.royalty = 0.0 if royalty.blank?
  end
end
