# frozen_string_literal: true

class ViewModalsController < ApplicationController
  def create
    render params[:type]
  end
end
