# frozen_string_literal: true

# == Schema Information
#
# Table name: mixin_assets
#
#  id         :uuid             not null, primary key
#  name       :string
#  raw        :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MixinAsset < ApplicationRecord
  store_accessor :raw, %i[icon_url symbol]

  before_validation :setup_attributes

  validates :name, presence: true, uniqueness: true
  validates :raw, presence: true

  private

  def setup_attributes
    r = TridentAssistantBot.api.asset id

    assign_attributes(
      id: r['asset_id'],
      name: r['name'],
      raw: r['data']
    )
  end
end
