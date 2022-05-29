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
class WithdrawNftTask < Task
  store_accessor :params, %i[identifier]

  validates :identifier, presence: true

  def process!
    return unless pending?

    r = user.trident_api.withdraw collection_id, identifier

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
end
