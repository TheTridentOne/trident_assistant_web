# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id            :uuid             not null, primary key
#  description   :text
#  identifier    :string
#  metadata      :jsonb
#  metahash      :string
#  name          :string
#  royalty       :float
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :uuid
#  token_id      :uuid
#
# Indexes
#
#  index_items_on_collection_id  (collection_id)
#  index_items_on_identifier     (identifier)
#  index_items_on_metahash       (metahash)
#  index_items_on_token_id       (token_id)
#
require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
