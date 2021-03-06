# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include RenderingHelper

  rescue_from StandardError do |ex|
    Rails.logger.error ex.inspect
    raise ex unless Rails.env.production?

    render_flash :danger, ex.message
  end

  before_action :authenticate!
  helper_method :current_user

  add_flash_types :success, :warning, :danger, :info

  private

  def authenticate!
    redirect_to login_path if current_user.blank?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id])
  end

  def user_sign_in(user)
    session[:current_user_id] = user.id
    LoginNotification.with({}).deliver_later(user)
  end

  def user_sign_out
    session[:current_user_id] = nil
    @current_user = nil
  end
end
