# frozen_string_literal: true

class ViewModalsController < ApplicationController
  def create
    case params[:type]
    when 'new_ask_order_task'
      render :new_ask_order_task
    when 'new_auction_order_task'
      render :new_auction_order_task
    when 'new_withdraw_task'
      render :new_withdraw_task
    when 'new_deposit_task'
      render :new_deposit_task
    when 'new_cancel_order_task'
      render :new_cancel_order_task
    when 'new_transfer_task'
      render :new_transfer_task
    else
      render params[:type]
    end
  end
end
