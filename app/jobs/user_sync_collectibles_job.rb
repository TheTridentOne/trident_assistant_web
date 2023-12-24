# frozen_string_literal: true

class UserSyncCollectiblesJob < ApplicationJob
  queue_as :critical

  def perform(id)
    User.find_by(id: id)&.sync_collectibles!
  end
end
