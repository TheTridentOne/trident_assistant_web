# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    keystore = File.read(params[:keystore])

    user = User.find_or_create_by keystore: keystore

    if user.present?
      user_sign_in user
      redirect_to root_path
    end
  end
end
