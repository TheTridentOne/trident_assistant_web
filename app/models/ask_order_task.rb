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
class AskOrderTask < Task
  attr_accessor :identifiers

  store_accessor :params, %i[identifier asset_id price expire_at time_zone]

  before_validation :setup_attributes, on: :create

  validates :identifier, presence: true
  validates :asset_id, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: MINIMUM_PRICE }
  validates :expire_at, presence: true

  def process!
    return unless pending?

    r =
      user.trident_api.ask_order(
        collection_id,
        identifier,
        asset_id: asset_id,
        price: price,
        expire_at: expire_at
      )

    update result: r['data']
    finish!
  rescue TridentAssistant::API::ForbiddenError,
         TridentAssistant::API::ArgumentError,
         TridentAssistant::API::UnauthorizedError,
         MixinBot::ForbiddenError,
         MixinBot::InsufficientBalanceError => e
    update result: { errors: e.inspect }
    fail!
  end

  private

  def setup_attributes
    self.expire_at =
      if expire_at.blank?
        7.days.from_now.utc.rfc3339
      else
        ActiveSupport::TimeZone[time_zone || 'UTC'].parse(expire_at)&.iso8601
      end
  end
end
