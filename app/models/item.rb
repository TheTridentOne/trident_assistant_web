# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id            :uuid             not null, primary key
#  description   :text
#  identifier    :string
#  metadata      :jsonb
#  metahash      :string
#  name          :string
#  royalty       :float
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :uuid
#  token_id      :uuid
#
# Indexes
#
#  index_items_on_collection_id_and_identifier  (collection_id,identifier) UNIQUE
#  index_items_on_metahash                      (metahash)
#  index_items_on_token_id                      (token_id) UNIQUE
#
class Item < ApplicationRecord
  include AASM

  has_one_attached :icon
  has_one_attached :media

  belongs_to :collection, optional: true

  has_many :non_fungible_outputs, primary_key: :token_id, foreign_key: :token_id, dependent: :nullify, inverse_of: :item
  has_many :tasks, primary_key: :token_id, foreign_key: :token_id, dependent: :nullify, inverse_of: :item

  before_validation :setup_token_id, :setup_royalty

  validates :royalty, numericality: { in: 0..0.10 }
  validates :name, presence: true
  validates :metadata, presence: true
  validates :metahash, presence: true, uniqueness: true
  validates :identifier, presence: true, format: { with: /\A(?!0)\d+\z/ }, uniqueness: { scope: :collection_id }

  scope :order_by_id, -> { order('identifier::integer ASC') }

  aasm column: :state do
    state :drafted, initialize: true
    state :minted

    event :mint, after: :sync_creator_collectibles do
      transitions from: :drafted, to: :minted
    end
  end

  def icon_url
    @icon_url ||= metadata.dig('token', 'icon', 'url')
  end

  def sync_creator_collectibles
    UserSyncCollectiblesJob.perform_in 30.seconds, collection&.creator_id
  end

  def refresh_metadata!
    _metadata =
      metadata
      .deep_merge(
        {
          'token' => {
            'media' => {
              'hash' => TridentAssistant::Utils.hash_from_url(metadata.dig('token', 'media', 'url'))
            }
          },
          'collection' => {
            'icon' => {
              'url' => collection.icon_url
            }
          }
        }
      )
    _metadata = TridentAssistant::Utils::Metadata.new(**_metadata.with_indifferent_access)
    update! metadata: _metadata.json, metahash: _metadata.metahash
  end

  private

  def setup_token_id
    return unless drafted?

    self.token_id = MixinBot::Utils::Nfo.new(collection: collection_id, token: identifier).unique_token_id
  end

  def setup_royalty
    self.royalty = 0.0 if royalty.blank?
  end
end
