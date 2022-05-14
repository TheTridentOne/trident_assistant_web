# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id           :uuid             not null, primary key
#  description  :text
#  external_url :string
#  name         :string
#  split        :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :uuid
#
# Indexes
#
#  index_collections_on_creator_id  (creator_id)
#
class Collection < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  has_many :items, dependent: :restrict_with_exception
end
