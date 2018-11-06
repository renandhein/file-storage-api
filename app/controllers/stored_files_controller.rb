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
    # and return all the errors
    if _errors.none? && _stored_file.save
      render(json: {"uuid": _stored_file.id}, status: :created)
    else
      render(json: {"errors": _errors}, status: :bad_request)
    end
  end

  def files
    _positive_tags = []
    _negative_tags = []

    # Separate the search query into positive and negative tags to be used in the query
    query_params["tag_query_search"].split(" ").each do |_tag|
      _positive_tags << _tag[1..-1] if _tag.starts_with?("+")
      _negative_tags << _tag[1..-1] if _tag.starts_with?("-")
    end

    # Assemble the query based on which types of parameters exist so it works
    # whether we have both or only one of them
    _stored_files = StoredFile.distinct.joins(:tags)
    if _positive_tags.any?
      _stored_files = _stored_files.where("tags.name" => _positive_tags).group("stored_files.id").having("COUNT(stored_files.id) = ?", _positive_tags.size)
    end
    if _negative_tags.any?
      _stored_files = _stored_files.where.not(:id => StoredFile.select(:id).joins(:tags).where("tags.name" => _negative_tags))
    end
    _stored_files = _stored_files.all.to_a

    # Find all tags belonging to the found files, but excluding the tags appearing in the search query
    _related_tags = Tag.distinct.joins(:stored_files).where(stored_files: {id: _stored_files.map(&:id)}).where.not(name: (_positive_tags + _negative_tags)).all.to_a

    render(json: {
      "total_records": _stored_files.size,
      "related_tags": _related_tags.map do |_tag|
        {
          "tag" => _tag.name,
          "file_count" => _tag.stored_files.where(stored_files: {id: _stored_files.map(&:id)}).count
        }
      end,
      "records": _stored_files.map do |_stored_file|
        {
          "uuid" => _stored_file.id,
          "name" => _stored_file.name
        }
      end
    }, status: :ok)
  end

  private
    def file_params
      params.permit(:name, tags: [])
    end

    def query_params
      params.permit(:tag_query_search, :page)
    end
end
