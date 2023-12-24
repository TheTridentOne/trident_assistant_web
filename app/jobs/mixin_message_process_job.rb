# frozen_string_literal: true

class MixinMessageProcessJob < ApplicationJob
  retry_on StandardError, attempts: 5

  def perform(id)
    MixinMessage.find_by(id: id)&.process!
  rescue MixinBot::ForbiddenError, MixinBot::UnauthorizedError => e
    Rails.logger.error e
  end
end
