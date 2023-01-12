# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to collections_path
  end

  def authorize_trident
    code =
      current_user
      .mixin_api.authorize_code(
        user_id: '6f5a84ce-d663-451e-b413-2d0c84b7629d',
        scope: ['PROFILE:READ', 'COLLECTIBLES:RESD']
      )
    redirect_to "https://thetrident.one/auth/mixin/callback?code=#{code}", allow_other_host: true
  end
end
