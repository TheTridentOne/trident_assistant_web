# frozen_string_literal: true

class Collections::GenerateNftTasksController < Collections::BaseController
  def create
    @task = current_user.tasks.new task_params

    redirect_to collection_tasks_path(@collection.id) if @task.save
  end

  private

  def task_params
    params
      .require(:generate_nft_task)
      .permit(:type, :collection_id, :royalty, :metadata, :assets)
  end
end
