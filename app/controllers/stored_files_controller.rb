class StoredFilesController < ApplicationController
  def file
    _stored_file = StoredFile.new(name: file_params[:name])

    if _stored_file.save
      render(json: {"uuid": _stored_file.id}, status: :created)
    else
      render(json: {"errors": _stored_file.errors.full_messages}, status: :bad_request)
    end
  end

  private
    def file_params
      params.permit(:name, tags: [])
    end
end
