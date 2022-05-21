# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate!

  def create
    return if params[:keystore].blank?

    user = User.auth_from_keystore params[:keystore]
    user_sign_in(user) if user.present?

    user&.sync_collections_from_trident
    user&.sync_collectibles_async

    redirect_to root_path
  end

  def destroy
    user_sign_out
    redirect_to root_path
  end
end
