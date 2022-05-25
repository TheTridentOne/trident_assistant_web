# frozen_string_literal: true

class Collections::BaseController < ApplicationController
  before_action :load_collection

  private

  def load_collection
    @collection = current_user.collections.find_by id: params[:collection_id]
    redirect_back fallback_location: root_path if @collection.blank?
    @nav_tab = 'collections'
  end
end
