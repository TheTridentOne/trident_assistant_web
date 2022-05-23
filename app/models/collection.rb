# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id           :uuid             not null, primary key
#  description  :text
#  external_url :string
#  name         :string
#  raw          :jsonb
#  split        :float
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :uuid
#
# Indexes
#
#  index_collections_on_creator_id  (creator_id)
#
class Collection < ApplicationRecord
  include AASM

  has_one_attached :icon

  belongs_to :creator, class_name: 'User'

  has_many :items, dependent: :restrict_with_exception

  before_validation :setup_attributes

  aasm column: :state do
    state :drafted, initialize: true
    state :listed

    event :list do
      transitions from: :drafted, to: :listed
    end
  end

  def icon_url
    @icon_url ||=
      if drafted?
        icon.url
      else
        raw.dig('icon', 'url')
      end
  end

  def trident_url
    "https://thetrident.one/collections/#{id}"
  end

  private

  def setup_attributes
    self.raw ||= TridentAssistant::API.new.collection(id) if new_record? && id.present? && raw.blank?
    return if raw.blank?

    assign_attributes(
      id: raw['id'],
      name: raw['name'],
      description: raw['description'],
      split: raw['split'],
      external_url: raw['external_url'],
      state: :listed
    )
  end
end
