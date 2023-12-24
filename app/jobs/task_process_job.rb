# frozen_string_literal: true

class TaskProcessJob < ApplicationJob
  retry_on MixinBot::InsufficientPoolError, MixinBot::PinError, waits: :exponentially_longer, attempts: Float::INFINITY

  def perform(id)
    Task.find_by(id: id)&.process!
  end
end
