# frozen_string_literal: true

class Collections::OrdersController < Collections::BaseController
  def index
    @type = params[:type] || 'all'
    @state = params[:state] || 'open'
    @maker = params[:maker] || current_user.id

    r = current_user.trident_api.orders(
      collection_id: @collection&.id,
      metahash: params[:metahash],
      type: @type,
      state: @state,
      maker_id: @maker,
      page: params[:page]
    )
    @orders = r['orders']
    @next_page = r['next_page']
    @prev_page = r['previous_page']
  end
end
