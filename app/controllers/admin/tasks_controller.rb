# frozen_string_literal: true

class Admin::TasksController < Admin::BaseController
  def index
    tasks = Task.all
    tasks = tasks.where(collection_id: params[:collection_id]) if params[:collection_id].present?

    tasks = tasks.where("params->>'identifier' = ?", params[:identifier].to_s) if params[:identifier].present?

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

    @pagy, @tasks = pagy tasks, items: 100
  end

  def show
    @task = Task.find params[:id]
  end
end
