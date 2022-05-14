# frozen_string_literal: true

# == Schema Information
#
# Table name: attributes
#
#  id         :uuid             not null, primary key
#  name       :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attributes_on_name_and_value  (name,value) UNIQUE
#
require 'test_helper'

class AttributeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
