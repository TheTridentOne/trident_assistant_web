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
class Task < ApplicationRecord
  MINIMUM_PRICE = 0.0001

  include AASM

  store_accessor :params, %i[identifier]

  belongs_to :user
  belongs_to :collection, optional: true
  belongs_to :item, primary_key: :token_id, foreign_key: :token_id, inverse_of: :tasks, optional: true

  before_validation :setup_token_id, on: :create

  validates :type, presence: true
  validate :ensure_not_create_duplicated_task

  after_commit :process_async, :notify, :broadcast, on: :create

  delegate :present?, to: :result, prefix: true

  aasm column: :state do
    state :pending, initialize: true
    state :processing
    state :failed
    state :finished
    state :cancelled

    event :start_process do
      transitions from: :pending, to: :processing
    end

    event :pend do
      transitions from: :processing, to: :pending
    end

    event :finish, guards: :result_present?, after_commit: %i[touch_processed_at notify broadcast] do
      transitions from: :processing, to: :finished
    end

    event :fail, guards: :result_present?, after_commit: %i[touch_processed_at notify broadcast] do
      transitions from: :processing, to: :failed
    end

    event :cancel, after: :touch_processed_at, after_commit: %i[notify broadcast] do
      transitions from: :pending, to: :cancelled
    end
  end

  def process_async
    TaskProcessJob.perform_async id
  end

  def process!
    raise 'Not implemented!'
  end

  def touch_processed_at
    update processed_at: Time.current
  end

  def notify
    return unless should_notify?

    TaskNotification.with(task: self).deliver_later(user)
  end

  def broadcast
    broadcast_append_later_to "user_#{user_id}", target: 'flashes', partial: 'flashes/flash', locals: { message: "#{type} for #{collection.name}(##{identifier}) #{state}", type: 'notice' }

    broadcast_replace_later_to "user_#{user_id}", target: "#{type.underscore}_#{id}", partial: 'collections/tasks/task', locals: { task: self }
  end

  def should_notify?
    true
  end

  private

  def ensure_not_create_duplicated_task
    return unless new_record?

    errors.add(:type, "There is a #{type} task in pending") if user.tasks.pending.order(created_at: :desc).find_by(type: type, token_id: token_id).present?
  end

  def setup_token_id
    self.token_id = MixinBot::Utils::Nfo.new(collection: collection_id, token: identifier).unique_token_id if identifier.present?

    self.collection_id = item.collection_id if item&.collection&.creator == user
  end
end
