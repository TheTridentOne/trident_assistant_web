# frozen_string_literal: true

class CollectionsController < ApplicationController
  def index
    @pagy, @collections = pagy current_user.collections.order(created_at: :desc)
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @collection = current_user.collections.find params[:id]
  end

  def sync
    current_user.sync_collections_from_trident
    redirect_to collections_path
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :split, :external_url)
  end
end
