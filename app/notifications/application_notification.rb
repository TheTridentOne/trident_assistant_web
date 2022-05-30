# frozen_string_literal: true

class ApplicationNotification < Noticed::Base
  def may_notify?
    recipient.creator_id.present?
  end
end
