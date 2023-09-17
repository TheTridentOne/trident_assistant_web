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
class FillOrderTask < Task
  store_accessor :params, %i[identifier order_id]

  before_validation :setup_identifier, on: :create

  validates :identifier, presence: true
  validates :order_id, presence: true

  def process!
    return unless pending?

    start_process!

    r = user.trident_api.fill_order order_id

    update result: r['data']
    finish!
  rescue TridentAssistant::API::ForbiddenError,
         TridentAssistant::API::ArgumentError,
         TridentAssistant::API::UnauthorizedError,
         MixinBot::ForbiddenError,
         MixinBot::InsufficientBalanceError => e
    update result: { errors: e.inspect }
    fail!
  ensure
    pend! if processing?
  end

  private

  def setup_identifier
    r = user.trident_api.order order_id
    self.identifier = r['item']['identifier']
    self.token_id = MixinBot::Utils::Nfo.new(collection: collection_id, token: identifier).unique_token_id if identifier.present?
  end
end
