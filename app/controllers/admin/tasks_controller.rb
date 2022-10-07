# frozen_string_literal: true

class Admin::TasksController < Admin::BaseController
  before_action :load_collection

  def index
    tasks = @collection.tasks

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
    @task = @collection.tasks.find params[:id]
  end

  private

  def load_collection
    @collection = Collection.find params[:collection_id]
  end
end
