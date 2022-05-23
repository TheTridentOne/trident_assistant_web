# frozen_string_literal: true

class ViewModalsController < ApplicationController
  def create
    @item = Item.find_by(metahash: params[:metahash]) if params[:metahash].present?

    case params[:type]
    when 'new_ask_order'
      render :new_ask_order
    when 'new_auction_order'
      render :new_auction_order
    else
      render params[:type]
    end
  end
end
