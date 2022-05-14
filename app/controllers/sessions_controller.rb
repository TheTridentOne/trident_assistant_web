# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    keystore = File.read(params[:keystore])

    json ||=
      begin
        JSON.parse keystore
      rescue StandardError
        {}
      end

    user = User.create_with(
      keystore: keystore
    ).find_or_create_by(
      id: json['client_id']
    )
    user.update(keystore: keystore) if user.present?

    user_sign_in(user) if user.blank?

    redirect_to root_path
  end
end
