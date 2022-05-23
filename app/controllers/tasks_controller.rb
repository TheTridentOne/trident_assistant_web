# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :load_collection

  def index
    tasks = @collection.tasks

    @state = params[:state] || 'all'
    tasks =
      case @state
      when 'all'
        tasks
      else
        tasks.where(state: @state)
      end

    @type = params[:type] || 'all'
    tasks =
      case @type
      when 'all'
        tasks
      else
        tasks.where(type: @type)
      end

    @order_by = params[:order_by] || 'created_at_desc'
    tasks =
      case @order_by
      when 'created_at_desc'
        tasks.order(created_at: :desc)
      when 'created_at_asc'
        tasks.order(created_at: :asc)
      when 'finished_at_desc'
        tasks.order(finished_at: :desc)
      when 'finished_at_asc'
        tasks.order(finished_at: :asc)
      end

    @pagy, @tasks = pagy tasks
  end

  def create
    task_params =
      if params[:ask_order_task].present?
        params.require(:ask_order_task).permit(:identifier, :asset_id, :price, :expire_at, :time_zone).merge(type: 'AskOrderTask')
      elsif params[:auction_order_task].present?
        params.require(:auction_order_task).permit(:identifier, :asset_id, :price, :reserve_price, :expire_at, :time_zone).merge(type: 'AuctionOrderTask')
      elsif params[:withdraw_task].present?
        params.require(:withdraw_task).permit(:identifier).merge(type: 'WithdrawTask')
      elsif params[:deposit_task].present?
        params.require(:deposit_task).permit(:identifier).merge(type: 'DepositTask')
      elsif params[:cancel_order_task].present?
        params.require(:cancel_order_task).permit(:identifier, :order_id).merge(type: 'CancelOrderTask')
      end

    @task = current_user.tasks.new task_params.merge(collection_id: @collection.id)

    redirect_to collection_tasks_path(@collection.id), success: 'Task created' if @task.save
  end

  private

  def load_collection
    @collection = current_user.collections.find_by id: params[:collection_id]
  end
end
