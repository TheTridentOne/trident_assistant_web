# frozen_string_literal: true

class Collections::ItemsController < Collections::BaseController
  before_action :load_item, only: %i[show edit update destroy]

  def index
    @query = params[:query].to_s.strip
    @type = params[:type] || 'all'

    case @type
    when 'drafted', 'all'
      items =
        if @type == 'drafted'
          Item.drafted
        else
          Item.all
        end

      @pagy, @items = pagy(
        items
        .where(collection_id: @collection.id)
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
    when 'wallet'
      @pagy, @items = pagy(
        current_user
        .items
        .where(collection_id: params[:collection_id]),
        items: 100
      )
    end
  end

  def new
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
    @item.destroy! if @item.drafted?

    redirect_to collection_items_path(@collection)
  end

  def bulk_destroy
    (params[:identifiers] || []).each do |identifier|
      item = @collection.items.find_by identifier: identifier
      item.destroy! if item.drafted?
    end

    redirect_to collection_items_path(@collection, tab: 'drafted')
  end

  private

  def load_item
    @item = @collection.items.find params[:id]
  end
end
