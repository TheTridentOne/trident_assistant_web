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
#  index_items_on_collection_id  (collection_id)
#  index_items_on_identifier     (identifier)
#  index_items_on_metahash       (metahash)
#  index_items_on_token_id       (token_id)
#
class Item < ApplicationRecord
  include AASM

  has_one_attached :icon
  has_one_attached :media

  belongs_to :collection, optional: true

  has_many :non_fungible_outputs, primary_key: :token_id, foreign_key: :token_id, dependent: :restrict_with_exception, inverse_of: :item
  has_many :tasks, primary_key: :token_id, foreign_key: :token_id, dependent: :nullify, inverse_of: :item

  before_validation :setup_meta

  validates :name, presence: true
  validates :metadata, presence: true
  validates :metahash, presence: true, uniqueness: true
  validates :identifier, presence: true, format: { with: /\A(?!0)\d+\z/ }, uniqueness: { scope: :collection_id }

  aasm column: :state do
    state :drafted, initialize: true
    state :minted

    event :mint do
      transitions from: :drafted, to: :minted
    end
  end

  def icon_url
    @icon_url ||=
      if drafted?
        icon.url
      else
        metadata.dig('token', 'icon', 'url')
      end
  end

  private

  def setup_meta
    return unless drafted?
  end
end
