# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :load_collection

  def index
    @type = params[:type] || 'all'
    @state = params[:state] || 'open'

    r = current_user.trident_api.orders(
      collection_id: @collection&.id,
      metahash: params[:metahash],
      type: @type,
      state: @state,
      page: params[:page]
    )
    @orders = r['orders']
    @next_page = r['next_page']
    @prev_page = r['previous_page']
  end

  private

  def load_collection
    @collection = Collection.find_by id: params[:collection_id]
  end
end
