require 'rails_helper'

RSpec.describe "StoredFiles", type: :request do
  describe "POST /file" do
    it "creates a new file and returns its uuid" do
      post "/file", :params => { :name => "test.txt" }

      # Make sure the file was created
      _stored_file = StoredFile.first
      expect(_stored_file).to be_an_instance_of(StoredFile)

      # Make sure the response has the right parameters
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:created)

      # Make sure the response has the right response body
      _json_response = JSON.parse(response.body)
      expect(_json_response).to include("uuid" => _stored_file.id)
    end
  end

  it "returns an error if the file name is invalid" do
    # Send a request with a file name that is over 100 characters (101 characters)
    post "/file", :params => { :name => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies, neque venenatis portaa." }

    # Make sure the response has the right parameters
    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:bad_request)

    # Make sure the response has errors inside
    _json_response = JSON.parse(response.body)
    expect(_json_response.keys).to include("errors")
  end
end
