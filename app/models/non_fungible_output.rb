# frozen_string_literal: true

# == Schema Information
#
# Table name: non_fungible_outputs
#
#  id         :uuid             not null, primary key
#  raw        :jsonb
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token_id   :uuid
#  user_id    :uuid
#
# Indexes
#
#  index_non_fungible_outputs_on_token_id  (token_id)
#  index_non_fungible_outputs_on_user_id   (user_id)
#
class NonFungibleOutput < ApplicationRecord
  store_accessor :raw, %i[updated_at], prefix: true

  belongs_to :user
  belongs_to :item, primary_key: :token_id, foreign_key: :token_id, inverse_of: :non_fungible_outputs

  before_validation :setup_attributes

  default_scope -> { order(Arel.sql("(raw->>'updated_at')::timestamptz desc")) }

  private

  def setup_attributes
    assign_attributes(
      id: raw['output_id'],
      token_id: raw['token_id'],
      state: raw['state'],
      user_id: raw['user_id']
    )
  end
end
