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
class MintNftTask < Task
  store_accessor :params, %i[identifier trace_id]

  before_validation :setup_trace_id

  validates :identifier, presence: true
  validates :trace_id, presence: true

  def process!
    return unless pending?

    collectible =
      begin
        user.trident_api.mixin_bot.collectible token_id
      rescue MixinBot::NotFoundError
        nil
      end
    if collectible.present?
      ActiveRecord::Base.transaction do
        update result: collectible
        finish!
        item.mint! if item.drafted?
      end

      return
    end

    if metadata.metahash != item.metahash
      update result: { errors: 'Invalid Metahash' }
      fail!
      return
    end

    uploaded = upload_metadata
    payment = mint!

    ActiveRecord::Base.transaction do
      update result: { upload: uploaded, payment: payment }
      finish!
      item.mint! if item.drafted?
    end
  rescue TridentAssistant::API::ForbiddenError,
         TridentAssistant::API::ArgumentError,
         TridentAssistant::API::UnauthorizedError,
         TridentAssistant::Utils::Metadata::InvalidFormatError,
         MixinBot::ForbiddenError,
         MixinBot::InsufficientBalanceError => e
    update result: { errors: e.inspect }
    fail!
  end

  def metadata
    @metadata ||= TridentAssistant::Utils.parse_metadata(item.metadata)
  end

  def mint_memo
    @mint_memo ||=
      user.trident_api.mixin_bot.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash
  end

  def upload_metadata
    user.trident_api.upload_metadata metadata: metadata.json, metahash: item.metahash
  end

  def mint!
    user.trident_api.mixin_bot.create_multisig_transaction(
      user.trident_api.keystore[:pin],
      {
        asset_id: TridentAssistant::Utils::MINT_ASSET_ID,
        trace_id: trace_id,
        amount: TridentAssistant::Utils::MINT_AMOUNT,
        memo: mint_memo,
        receivers: TridentAssistant::Utils::NFO_MTG[:members],
        threshold: TridentAssistant::Utils::NFO_MTG[:threshold]
      }
    )
  end

  private

  def setup_trace_id
    return unless new_record?

    self.trace_id = SecureRandom.uuid if trace_id.blank?
  end
end
