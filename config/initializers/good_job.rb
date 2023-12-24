# frozen_string_literal: true

Rails.application.configure do
  config.active_job.queue_adapter = :good_job

  config.good_job.execution_mode = :async
  config.good_job.max_threads = 5
  config.good_job.enable_cron = true
  config.good_job.cron = {
    send_signed_transaction_job: {
      cron: '*/15 * * * *',
      class: 'SendSignedTransactionJob'
    }
  }
end
