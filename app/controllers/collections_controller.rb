# frozen_string_literal: true

class CollectionsController < ApplicationController
  before_action :load_collection, only: %i[edit update show destroy]

  def index
    @pagy, @collections = pagy current_user.collections.order(created_at: :desc)
    @nav_tab = 'collections'
  end

  def new
  end

  def create
    @collection = current_user.collections.new collection_params

    redirect_to collections_path, success: 'Created' if @collection.save
  end

  def edit
  end

  def update
    if collection_params[:icon].present?
      @collection.assign_attributes(
        icon: collection_params[:icon]
      )
    end

    r =
      current_user
      .trident_api
      .update_collection(
        @collection.id,
        description: collection_params[:description],
        external_url: collection_params[:external_url],
        icon_url: @collection.icon.changed? ? @collection.icon.url : ''
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
    current_user.sync_collectibles_async
    render_flash :success, 'Syncing from Trident, please refresh page later'
  end

  def destroy
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :split, :external_url, :icon)
  end

  def load_collection
    @collection = current_user.collections.find params[:id]
    @nav_tab = 'collections'
  end
end
