# frozen_string_literal: true

class CollectionsController < ApplicationController
  before_action :load_collection, only: %i[edit update show]

  def index
    @pagy, @collections = pagy current_user.collections.order(created_at: :desc)
    @nav_tab = 'collections'
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    r =
      current_user
      .trident_api
      .update_collection(
        @collection.id,
        description: collection_params[:description],
        external_url: collection_params[:external_url]
      )

    if @collection.update raw: r
      redirect_to collections_path, success: 'Updated'
    else
      render_flash :danger, @collection.errors.full_messages.join(';')
    end
  end

  def show
  end

  def sync
    current_user.sync_collections_from_trident
    render_flash :success, 'Syncing from Trident, please refresh page later'
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :split, :external_url)
  end

  def load_collection
    @collection = current_user.collections.find params[:id]
    @nav_tab = 'collections'
  end
end
