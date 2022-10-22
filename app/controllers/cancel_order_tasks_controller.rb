# frozen_string_literal: true

class CancelOrderTasksController < ApplicationController
  before_action :set_navtab

  def create
    successes = []
    @errors = []

    order_ids = params.dig(:cancel_order_task, :order_ids) || []

    order_ids.each do |order_id|
      task = current_user.tasks.create task_params.merge(order_id: order_id)
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
      .require(:cancel_order_task)
      .permit(:type, :collection_id)
  end

  def set_navtab
    @nav_tab = 'tasks'
  end
end
