# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :load_collection

  def index
    r = current_user.trident_api.orders(
      collection_id: @collection&.id,
      metahash: params[:metahash],
      type: params[:type],
      state: params[:state],
      page: params[:page]
    )
    @orders = r['orders']
    @next_page = r['next_page']
    @previous_page = r['previous_page']
  end

  def new
  end

  def create
  end

  def destroy
    r = current_user.trident_api.cancel_order params[:order_id]

    if r['data'].present?
      render_flash :success, 'Successfully to invoke cancel! Refresh page later'
    else
      render_flash :error, r['errors']
    end
  rescue MixinBot::Error, TridentAssistant::Error => e
    render_flash :error, e.inspect
  end

  private

  def load_collection
    @collection = Collection.find_by id: params[:collection_id]
  end
end
