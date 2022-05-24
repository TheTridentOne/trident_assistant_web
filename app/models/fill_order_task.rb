# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id            :uuid             not null, primary key
#  params        :jsonb
#  processed_at  :datetime
#  result        :jsonb
#  state         :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :uuid
#  token_id      :uuid
#  user_id       :uuid
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#
class FillOrderTask < Task
  store_accessor :params, %i[identifier order_id]

  validates :identifier, presence: true
  validates :order_id, presence: true

  def process!
    r = user.trident_api.fill_order order_id

    if r['data'].present?
      update result: r['data']
      finish!
    else
      update result: r
      fail!
    end
  end
end
