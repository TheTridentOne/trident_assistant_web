# frozen_string_literal: true

class Collections::FillOrderTasksController < Collections::BaseController
  def create
    successes = []
    @errors = []

    (task_params.delete(:order_ids) || [])&.each do |order_id|
      task = current_user.tasks.create task_params.merge(order_id: order_id)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    redirect_to collection_tasks_path(@collection.id), success: "#{successes.count} task created" if successes.present?
  end

  private

  def task_params
    params
      .require(:fill_order_task)
      .permit(:type, :collection_id, :order_ids)
  end
end
