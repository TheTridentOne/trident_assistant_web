# frozen_string_literal: true

# == Schema Information
#
# Table name: mixin_messages
#
#  id           :uuid             not null, primary key
#  processed_at :datetime
#  raw          :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :uuid
#  sender_id    :uuid
#
# Indexes
#
#  index_mixin_messages_on_recipient_id  (recipient_id)
#  index_mixin_messages_on_sender_id     (sender_id)
#
class MixinMessage < ApplicationRecord
  belongs_to :sender, class_name: 'User'

  validates :raw, presence: true
  validates :recipient_id, presence: true

  after_commit :process_async, on: :create

  def process_async
    MixinMessageProcessJob.perform_async id
  end

  def process!
    sender.mixin_api.create_contact_conversation recipient_id
    sender.mixin_api.send_message raw
    touch_processed_at
  end

  def touch_processed_at
    update processed_at: Time.current
  end
end
