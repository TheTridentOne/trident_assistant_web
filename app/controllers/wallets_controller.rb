# frozen_string_literal: true

class WalletsController < ApplicationController
  def show
    @tab = params[:tab] || 'assets'
    @nav_tab = 'wallet'
  end

  def assets
    @assets = current_user.mixin_api.assets['data']
  end

  def items
    current_user.sync_collectibles_async
    @pagy, @items = pagy_countless current_user.items
  end

  def snapshots
    limit = 25
    @snapshots = current_user.mixin_api.snapshots(limit: limit, offset: params[:offset])['data']
    @has_next = @snapshots.size >= limit
  end
end
