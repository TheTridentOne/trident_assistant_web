# frozen_string_literal: true

class Admin::ItemsController < Admin::BaseController
  before_action :load_collection

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

  def show
    @item = @collection.items.find params[:id]
  end

  private

  def load_collection
    @collection = Collection.find params[:collection_id]
  end
end
