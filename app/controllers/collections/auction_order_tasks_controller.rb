# frozen_string_literal: true

class Collections::AuctionOrderTasksController < Collections::BaseController
  def create
    successes = []
    @errors = []

    identifiers = params.dig(:auction_order_task, :identifiers) || []

    identifiers.each do |identifier|
      task = current_user.tasks.create task_params.merge(identifier: identifier)
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
      .require(:auction_order_task)
      .permit(:type, :collection_id, :asset_id, :price, :reserve_price, :expire_at, :time_zone)
  end
end
