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
#  token_id   :uuid             not null
#  user_id    :uuid
#
# Indexes
#
#  index_non_fungible_outputs_on_token_id  (token_id)
#  index_non_fungible_outputs_on_user_id   (user_id)
#
require 'test_helper'

class NonFungibleOutputTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
