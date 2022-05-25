# frozen_string_literal: true

class Collections::ItemsController < Collections::BaseController
  def index
    @query = params[:query].to_s.strip
    @type = params[:type] || 'wallet'

    case @type
    when 'drafted'
      @pagy, @items = pagy(
        Item
        .drafted
        .where(collection_id: @collection&.id)
        .ransack(
          {
            name_i_cont_any: @query,
            description_i_cont_any: @query,
            identifier_cont_all: @query,
            meta_hash_cont_all: @query
          }.merge(m: 'or')
        ).result
      )

      @next_page = @pagy.next
      @prev_page = @pagy.prev
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
      current_user.sync_collectibles_async
      @pagy, @items = pagy current_user.items.where(collection_id: params[:collection_id])

      @next_page = @pagy.next
      @prev_page = @pagy.prev
    end
  end

  def withdraw
    item = Item.find params[:item_id]
    r = current_user.trident_api.withdraw @collection.id, item.identifier

    if r['data'].present?
      render_flash :success, 'Successfully to invoke withdraw! Refresh page later'
    else
      render_flash :error, r['errors']
    end
  rescue MixinBot::Error, TridentAssistant::Error => e
    render_flash :error, e.inspect
  end

  def deposit
    item = Item.find params[:item_id]
    r = current_user.trident_api.deposit @collection.id, item.identifier

    if r['data'].present?
      render_flash :success, 'Successfully to invoke deposit! Refresh page later'
    else
      render_flash :error, r['errors']
    end
  rescue MixinBot::Error, TridentAssistant::Error => e
    render_flash :error, e.inspect
  end
end
