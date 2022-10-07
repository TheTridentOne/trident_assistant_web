# frozen_string_literal: true

class Admin::CollectionsController < Admin::BaseController
  def index
    @pagy, @collections = pagy Collection.all.order(created_at: :desc)
  end
end
