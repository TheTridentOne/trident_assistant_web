# frozen_string_literal: true

# == Schema Information
#
# Table name: mixin_assets
#
#  id         :uuid             not null, primary key
#  name       :string
#  raw        :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class MixinAssetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
