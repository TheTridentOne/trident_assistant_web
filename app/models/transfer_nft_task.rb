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
class TransferNftTask < Task
  store_accessor :params, %i[identifier recipient_id]

  before_validation :setup_recipient_id

  validates :identifier, presence: true
  validates :recipient_id, presence: true

  def process!
    return unless pending?

    start_process!

    r = user.trident_api.transfer collection_id, identifier, recipient_id

    update result: r['data']
    finish!
  rescue TridentAssistant::API::ForbiddenError,
         TridentAssistant::API::ArgumentError,
         TridentAssistant::API::UnauthorizedError,
         MixinBot::ForbiddenError,
         MixinBot::InsufficientBalanceError => e
    update! result: { errors: e.inspect }
    fail!
  ensure
    pend! if processing?
  end

  private

  def setup_recipient_id
    r = user.mixin_api.read_user recipient_id

    self.recipient_id = r['user_id']
  end
end
