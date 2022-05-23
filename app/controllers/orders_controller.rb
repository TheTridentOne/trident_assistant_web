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
    @prev_page = r['previous_page']
  end

  def create
    expire_at = ActiveSupport::TimeZone[params[:time_zone] || 'UTC'].parse(params[:expire_at])&.iso8601

    r =
      case params[:type]
      when 'ask_order'
        current_user.trident_api.ask_order(
          @collection.id,
          params[:identifier],
          asset_id: params[:asset_id],
          price: params[:price],
          expire_at: expire_at
        )
      when 'auction_order'
        current_user.trident_api.auction_order(
          @collection.id,
          params[:identifier],
          asset_id: params[:asset_id],
          price: params[:price],
          reserve_price: params[:reserve_price],
          expire_at: expire_at
        )
      end

    if r['data'].present?
      redirect_to collection_orders_path(@collection.id), success: 'Successfully to invoke new order! Refresh page later'
    else
      render_flash :danger, r['errors']
    end
  rescue MixinBot::Error, TridentAssistant::Error => e
    render_flash :danger, e.inspect
  end

  def destroy
    r = current_user.trident_api.cancel_order params[:id]

    if r['data'].present?
      render_flash :success, 'Successfully to invoke cancel! Refresh page later'
    else
      render_flash :danger, r['errors']
    end
  rescue MixinBot::Error, TridentAssistant::Error => e
    render_flash :danger, e.inspect
  end

  private

  def load_collection
    @collection = Collection.find_by id: params[:collection_id]
  end
end
