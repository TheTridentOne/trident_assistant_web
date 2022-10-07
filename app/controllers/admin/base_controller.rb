# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_admin!

  def authenticate_admin!
    current_user.admin?
  end
end
