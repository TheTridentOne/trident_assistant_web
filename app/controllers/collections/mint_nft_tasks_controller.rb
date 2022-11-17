# frozen_string_literal: true

class Collections::MintNftTasksController < Collections::BaseController
  before_action :ensure_collection_listed

  def create
    successes = []
    @errors = []

    token_ids = params.dig(:mint_nft_task, :token_ids) || []

    token_ids.each do |token_id|
      item = Item.find_by token_id: token_id
      task = current_user.tasks.create task_params.merge(identifier: item.identifier)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    redirect_to tasks_path(collection_id: @collection.id), success: "#{successes.count} task created" if successes.present?
  end

  private

  def task_params
    params
      .require(:mint_nft_task)
      .permit(:type, :collection_id)
  end

  def ensure_collection_listed
    redirect_to collection_items_path(@collection.id), danger: 'List collection first' if @collection.drafted?
  end
end
