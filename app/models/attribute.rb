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
class Attribute < ApplicationRecord
  has_many :item_attributes, dependent: :restrict_with_exception
  has_many :items, through: :item_attributes, dependent: :restrict_with_exception
end
