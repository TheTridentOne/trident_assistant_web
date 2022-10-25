# frozen_string_literal: true

class TransferNftTasksController < ApplicationController
  def create
    successes = []
    @errors = []

    token_ids = params.dig(:transfer_nft_task, :token_ids) || []

    token_ids.each do |token_id|
      task = current_user.tasks.create task_params.merge(token_id: token_id)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    redirect_to tasks_path(collection_id: params[:collection_id]), success: "#{successes.count} task created" if successes.present?
  end

  private

  def task_params
    params
      .require(:transfer_nft_task)
      .permit(:type, :collection_id, :recipient_id)
  end
end
