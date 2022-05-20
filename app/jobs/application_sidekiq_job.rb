# frozen_string_literal: true

class ApplicationSidekiqJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
end
