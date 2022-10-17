# frozen_string_literal: true

class Collections::AttachmentsController < Collections::BaseController
  def index
    @attachments = @collection.attachments.includes(:blob).order('active_storage_blobs.filename ASC')
  end

  def new
  end

  def destroy
    @attachment = @collection.attachments.find params[:id]
    @attachment.purge
  end
end
