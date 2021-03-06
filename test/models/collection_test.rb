# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id           :uuid             not null, primary key
#  description  :text
#  external_url :string
#  name         :string
#  raw          :jsonb
#  split        :float
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :uuid
#
# Indexes
#
#  index_collections_on_creator_id  (creator_id)
#
require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
