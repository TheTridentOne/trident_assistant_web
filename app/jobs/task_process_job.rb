# frozen_string_literal: true

class TaskProcessJob < ApplicationJob
  def perform(id)
    Task.find_by(id: id)&.process!
  end
end
