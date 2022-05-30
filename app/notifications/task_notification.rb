# frozen_string_literal: true

class TaskNotification < ApplicationNotification
  deliver_by :mixin_bot, class: 'DeliveryMethods::MixinBot', category: 'PLAIN_TEXT'

  param :task

  def task
    params[:task]
  end

  def plain_text_data
    [task.type, "for #{task.collection.name}", (task.identifier.present? ? "(##{task.identifier})" : ''), task.state].join(' ')
  end
end
