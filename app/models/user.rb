# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  keystore   :text
#  name       :string
#  raw        :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mixin_id   :string
#
class User < ApplicationRecord
  include Users::Authenticatable

  encrypts :keystore

  store_accessor :raw, %i[avatar_url biography]

  before_validation :setup_attributes

  validates :name, presence: true
  validates :mixin_id, presence: true
  validates :keystore, presence: true
  validates :raw, presence: true

  has_many :collections, foreign_key: :creator_id, dependent: :restrict_with_exception, inverse_of: :creator
  has_many :non_fungible_outputs, dependent: :restrict_with_exception
  has_many :unspent_non_fungible_outputs, -> { where(state: :unspent) }, class_name: 'NonFungibleOutput', dependent: :restrict_with_exception, inverse_of: :user
  has_many :signed_non_fungible_outputs, -> { where(state: :signed) }, class_name: 'NonFungibleOutput', dependent: :restrict_with_exception, inverse_of: :user
  has_many :items, through: :unspent_non_fungible_outputs, dependent: :restrict_with_exception
  has_many :tasks, dependent: :restrict_with_exception

  def keystore_json
    @keystore_json ||=
      begin
        JSON.parse keystore
      rescue JSON::ParseError
        {}
      end
  end

  def mixin_api
    @mixin_api ||= MixinBot::API.new(
      client_id: keystore_json['client_id'],
      session_id: keystore_json['session_id'],
      pin_token: keystore_json['pin_token'],
      private_key: keystore_json['private_key']
    )
  rescue StandardError
    nil
  end

  def trident_api
    @trident_api ||= TridentAssistant::API.new keystore: keystore
  end

  def sync_collections_from_trident
    loop do
      page = 1
      r = trident_api.collections(page: page)
      r['collections'].each do |c|
        collection =
          Collection.create_with(
            raw: c,
            creator_id: id
          ).find_or_create_by(
            id: c['id']
          )

        collection.update raw: c, creator_id: id
      end

      page = r['next_page']
      break if page.blank?
    end
  end

  def sync_collectibles!(restart: false)
    offset =
      if restart
        ''
      else
        non_fungible_outputs.first&.raw_updated_at
      end

    loop do
      logger.info "Syncing #{name}(#{id}) collectibles"
      r = mixin_api.collectibles offset: offset, limit: 500

      r['data'].each do |collectible|
        logger.info "found collectible #{collectible}"
        nfo = NonFungibleOutput.find_by id: collectible['output_id']
        if nfo.present?
          nfo.update! raw: collectible
        else
          token = mixin_api.collectible collectible['token_id']
          item = Item.find_by metahash: token.dig('meta', 'hash')
          if item.blank?
            res = trident_api.metadata token.dig('meta', 'hash')
            Item.create!(
              token_id: collectible['token_id'],
              collection: Collection.find_or_create_by(id: res.dig('collection', 'id')),
              name: res.dig('token', 'name'),
              description: res.dig('token', 'description'),
              identifier: res.dig('token', 'id'),
              metahash: token.dig('meta', 'hash'),
              royalty: res.dig('creator', 'royalty'),
              state: :minted,
              metadata: res
            )
          else
            item.update token_id: collectible['token_id']
            item.mint! if item.drafted?
          end
          non_fungible_outputs.create! raw: collectible
        end
      end

      offset = r['data'].last['updated_at'] if r['data'].size.positive?
      if r['data'].size < 500
        logger.info "#{name}(#{id}) collectibles synced"
        break
      end
    end
    true
  rescue MixinBot::HttpError
    retry
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    false
  end

  def sync_collectibles_async
    UserSyncCollectiblesJob.perform_async id
  end

  def admin?
    creator_id.in?(Rails.application.credentials[:admin] || [])
  end

  def own?(token_id)
    unspent_non_fungible_outputs.find_by(token_id: token_id).present?
  end

  def creator_id
    @creator_id ||= raw.dig('app', 'creator_id')
  end

  private

  def setup_attributes
    return if mixin_api.blank?

    r = mixin_api.me

    assign_attributes(
      id: r['user_id'],
      raw: r['data'],
      name: r['full_name'],
      mixin_id: r['identity_number'],
      keystore: keystore
    )
  end
end
