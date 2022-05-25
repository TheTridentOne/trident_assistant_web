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
      when 'processed_at_desc'
        tasks.order(processed_at: :desc)
      when 'processed_at_asc'
        tasks.order(processed_at: :asc)
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
      elsif params[:transfer_task].present?
        params.require(:transfer_task).permit(:recipient_id).merge(type: 'TransferTask')
      elsif params[:deposit_task].present?
        params.require(:deposit_task).permit(:identifier).merge(type: 'DepositTask')
      elsif params[:cancel_order_task].present?
        params.require(:cancel_order_task).permit(:identifier, :order_id).merge(type: 'CancelOrderTask')
      end

    successes = []
    @errors = []

    params[:identifiers]&.each do |identifier|
      task = current_user.tasks.create task_params.merge(collection_id: @collection.id, identifier: identifier)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    params[:order_ids]&.each do |order_id|
      task = current_user.tasks.create task_params.merge(collection_id: @collection.id, order_id: order_id)
      if task.save
        successes.push task.id
      else
        @errors.push task.errors.full_messages.join(';')
      end
    end

    redirect_to collection_tasks_path(@collection.id), success: "#{successes.count} task created" if successes.present?
  end

  def show
    @task = @collection.tasks.find params[:id]
  end

  private

  def load_collection
    @collection = current_user.collections.find_by id: params[:collection_id]
    redirect_back fallback_location: root_path if @collection.blank?
  end
end
