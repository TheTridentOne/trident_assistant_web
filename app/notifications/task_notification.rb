# frozen_string_literal: true

class TaskNotification < ApplicationNotification
  deliver_by :mixin_bot, class: 'DeliveryMethods::MixinBot', category: 'PLAIN_TEXT'

  param :task

  def task
    params[:task]
  end

  def message
    [task.type.underscore.humanize, "for #{task.collection.name}", (task.identifier.present? ? "(##{task.identifier})" : ''), task.state].join(' ')
  end

  def plain_text_data
    <<~TEXT
      == Task #{task.state} ==

      - Type: #{task.type.underscore.humanize}
      - Collection: #{task.collection.name}
      - Token: ##{task.identifier || '-'}

      (From: assistant.thetrident.one)
    TEXT
  end
end
