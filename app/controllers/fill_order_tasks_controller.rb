# frozen_string_literal: true

class FillOrderTasksController < Collections::BaseController
  def create
    successes = []
    @errors = []

    order_ids = params.dig(:fill_order_task, :order_ids) || []

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
      .require(:fill_order_task)
      .permit(:type, :collection_id)
  end
end
