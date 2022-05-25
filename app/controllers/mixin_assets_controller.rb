# frozen_string_literal: true

class WalletsController < ApplicationController
  skip_before_action :authenticate!

  def show
  end
end
