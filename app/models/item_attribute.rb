# frozen_string_literal: true

# == Schema Information
#
# Table name: item_attributes
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  attribute_id :uuid
#  item_id      :uuid
#
# Indexes
#
#  index_item_attributes_on_item_id_and_attribute_id  (item_id,attribute_id) UNIQUE
#
class ItemAttribute < ApplicationRecord
  belongs_to :item
  belongs_to :attribute
end
