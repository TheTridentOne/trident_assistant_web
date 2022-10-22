# frozen_string_literal: true

class DepositNftTasksController < ApplicationController
  def new
  end

  def create
    successes = []
    @errors = []

    identifiers = params.dig(:deposit_nft_task, :identifiers) || []

    identifiers.each do |identifier|
      task = current_user.tasks.create task_params.merge(identifier: identifier)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    redirect_to tasks_path(collection_id: task_params[:collection_id]), success: "#{successes.count} task created" if successes.present?
  end

  private

  def task_params
    params
      .require(:deposit_nft_task)
      .permit(:type, :collection_id)
  end
end
