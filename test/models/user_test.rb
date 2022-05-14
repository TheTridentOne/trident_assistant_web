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
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
