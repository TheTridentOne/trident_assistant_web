# frozen_string_literal: true

class SendSignedTransactionJob < ApplicationJob
  retry_on StandardError, attempts: 5

  queue_as :critical

  def perform
    NonFungibleOutput.where(state: 'signed').each do |nfo|
      nfo.user.mixin_api.send_raw_transaction nfo.raw['signed_tx']
      nfo.user.sync_collectibles_async
    end
  end
end
