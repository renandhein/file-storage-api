class StoredFilesController < ApplicationController
  def file
    # Create the file
    _stored_file = StoredFile.new(name: file_params[:name])
    _errors = []

    # If the file is valid, proceed
    if _stored_file.valid?
      # Check each supplied tag
      file_params[:tags].try(:each) do |_tag|
        # Check if the tag already exists. If not, create a new one
        _tag = Tag.where(name: _tag).first || Tag.new(name: _tag)

        # If the tag is valid, it can be added to the file
        if _tag.valid?
          _stored_file.tags << _tag
        else
          # Customize the error messages so that the requester can know which tag
          # contains which error
          _tag.errors.full_messages.each do |_error_message|
            _errors << "Tag '#{_tag.name}' is invalid: #{_error_message}"
          end
        end
      end
    else
      _errors = _errors + _stored_file.errors.full_messages
    end

    # If there are any pending errors in the file or in the tags, don't save
    # and return the errors
    if _errors.none? && _stored_file.save
      render(json: {"uuid": _stored_file.id}, status: :created)
    else
      render(json: {"errors": _errors}, status: :bad_request)
    end
  end

  private
    def file_params
      params.permit(:name, tags: [])
    end
end
