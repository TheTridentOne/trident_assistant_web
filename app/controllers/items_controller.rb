# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :load_collection

  def index
    @query = params[:query].to_s.strip
    @type = params[:type] || 'all'

    case @type
    when 'wallet'
      items = current_user.items
      items =
        if params[:collection_id].present?
          items.where(collection_id: params[:collection_id])
        else
          items.where.not(collection_id: current_user.collections.ids)
        end

      @pagy, @items = pagy items, items: 100
    when 'drafted'
      items =
        if @collection.present?
          Item.drafted.where(collection_id: @collection.id)
        else
          Item.none
        end

      @pagy, @items = pagy(
        items
        .ransack(
          {
            name_i_cont_any: @query,
            description_i_cont_any: @query,
            identifier_cont_all: @query,
            meta_hash_cont_all: @query
          }.merge(m: 'or')
        ).result,
        items: 100
      )
    when 'all'
      items =
        if @collection.present?
          Item.where(collection_id: @collection.id)
        else
          current_user.items
        end

      @pagy, @items = pagy(
        items
        .ransack(
          {
            name_i_cont_any: @query,
            description_i_cont_any: @query,
            identifier_cont_all: @query,
            meta_hash_cont_all: @query
          }.merge(m: 'or')
        ).result,
        items: 100
      )
    when 'airdrop', 'deposited', 'on_sale', 'on_auction', 'listed'
      r = current_user.trident_api.collectibles(
        collection_id: @collection&.id,
        type: @type,
        query: @query,
        page: params[:page]
      )
      @items = Item.where(metahash: r['collectibles'].map(&->(item) { item['metahash'] }))
      @next_page = r['next_page']
      @prev_page = r['previous_page']
    end
  end

  private

  def load_collection
    @collection = current_user.collections.find_by(id: params[:collection_id]) if params[:collection_id].present?
    @nav_tab = 'items'
  end
end
