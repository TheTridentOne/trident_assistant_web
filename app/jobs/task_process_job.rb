# frozen_string_literal: true

class TaskProcessJob < ApplicationSidekiqJob
  sidekiq_options queue: :high

  def perform(id)
    Task.find_by(id: id)&.process!
  end
end
