# frozen_string_literal: true

class LoginNotification < ApplicationNotification
  deliver_by :mixin_bot, class: 'DeliveryMethods::MixinBot', category: 'PLAIN_TEXT'

  def plain_text_data
    'Your Mixin Bot has logged in https://assistant.thetrident.one. If this is not you, please re-generate the keystore immediately.'
  end
end
