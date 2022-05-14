# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  keystore   :text
#  name       :string
#  raw        :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mixin_id   :string
#
class User < ApplicationRecord
  encrypts :keystore
  store_accessor :raw, %i[avatar_url biography]

  before_validation :setup_attributes

  validates :name, presence: true
  validates :mixin_id, presence: true
  validates :keystore, presence: true
  validates :raw, presence: true

  def keystore_json
    @keystore_json ||=
      begin
        JSON.parse keystore
      rescue JSON::ParseError
        {}
      end
  end

  def mixin_api
    @mixin_api ||= MixinBot::API.new(
      client_id: keystore_json['client_id'],
      session_id: keystore_json['session_id'],
      pin_token: keystore_json['pin_token'],
      private_key: keystore_json['private_key']
    )
  rescue StandardError
    nil
  end

  private

  def setup_attributes
    return if mixin_api.blank?

    r = mixin_api.me

    assign_attributes(
      id: r['user_id'],
      raw: r['data'],
      name: r['full_name'],
      mixin_id: r['identity_number'],
      keystore: keystore
    )
  end
end
