# frozen_string_literal: true

module Users::Authenticatable
  extend ActiveSupport::Concern

  class_methods do
    def auth_from_keystore(file)
      keystore = File.read file

      json ||=
        begin
          JSON.parse keystore
        rescue StandardError
          {}
        end

      user = create_with(
        keystore: keystore
      ).find_or_create_by(
        id: json['client_id']
      )
      user.update(keystore: keystore) if user.present?

      user
    rescue MixinBot::HttpError
      nil
    end
  end
end
