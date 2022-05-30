# frozen_string_literal: true

class DeliveryMethods::MixinBot < Noticed::DeliveryMethods::Base
  def deliver
    MixinMessage.create raw: format, sender: recipient, recipient_id: recipient.creator_id
  end

  def category
    options[:category] || 'PLAIN_TEXT'
  end

  def data
    case category
    when 'PLAIN_TEXT'
      notification.plain_text_data
    when 'APP_CARD'
      notification.app_card_data
    end
  end

  def conversation_id
    recipient.mixin_api.unique_conversation_id recipient.creator_id
  end

  def format
    recipient.mixin_api.base_message_params(
      {
        category: category,
        conversation_id: conversation_id,
        recipient_id: recipient.creator_id,
        data: data
      }
    )
  end
end
