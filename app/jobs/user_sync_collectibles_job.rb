# frozen_string_literal: true

class UserSyncCollectiblesJob < ApplicationSidekiqJob
  sidekiq_options queue: :default, retry: false

  def perform(id)
    User.find_by(id: id)&.sync_collectibles!
  end
end
