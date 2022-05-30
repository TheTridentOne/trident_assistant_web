# frozen_string_literal: true

class TaskProcessJob < ApplicationSidekiqJob
  sidekiq_options queue: :high

  sidekiq_retry_in do |count, exception|
    case exception
    when MixinBot::InsufficientPoolError, MixinBot::PinError
      SecureRandom.random_number(60) if count < 10
    end
  end

  def perform(id)
    Task.find_by(id: id)&.process!
  end
end
