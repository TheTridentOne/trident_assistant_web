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
require 'test_helper'

class MixinMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
