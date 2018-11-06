require 'rails_helper'

RSpec.describe "StoredFiles", type: :request do
  describe "POST /file" do
    it "creates a new file with associated tags and returns its uuid" do
      post "/file", :params => {:name => "test.txt", :tags => ["text"]}

      # Make sure the file was created
      _stored_file = StoredFile.first
      expect(_stored_file).to be_an_instance_of(StoredFile)

      # Make sure the tag was created
      _tag = Tag.first
      expect(_tag).to be_an_instance_of(Tag)

      # Make sure the tags were associated to the file
      expect(_stored_file.tags.first).to eq(_tag)

      # Make sure the response has the right parameters
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:created)

      # Make sure the response has the right response body
      _json_response = JSON.parse(response.body)
      expect(_json_response).to include("uuid" => _stored_file.id)
    end
  end

  it "returns an error if the file parameters are invalid" do
    # Send a request with a file name that is over 100 characters (101 characters)
    post "/file", :params => { :name => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies, neque venenatis portaa." }

    # Make sure the response has the right parameters
    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:bad_request)

    # Make sure the response has errors inside
    _json_response = JSON.parse(response.body)
    expect(_json_response.keys).to include("errors")
  end

  it "returns errors if the tags have invalid parameters" do
    # Send a request with a tag name containing invalid characters (whitespaces are invalid)
    post "/file", :params => {:name => "text.txt", :tags => ["foo bar"]}

    # Make sure the response has the right parameters
    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:bad_request)

    # Make sure the response has errors inside
    _json_response = JSON.parse(response.body)
    expect(_json_response.keys).to include("errors")

    # Make sure the error specifies the tag's error
    expect(_json_response["errors"].first).to eq("Tag 'foo bar' is invalid: Name contains invalid characters ('+', '-' or whitespaces are not allowed)")
  end

  describe "GET /files/<tag_query_search>/<page>" do
    before(:each) do
      FactoryBot.create(:stored_file, name: "File1", with_tags: ["Tag1", "Tag2", "Tag3", "Tag5"])
      FactoryBot.create(:stored_file, name: "File2", with_tags: ["Tag2"])
      FactoryBot.create(:stored_file, name: "File3", with_tags: ["Tag2", "Tag3", "Tag5"])
      FactoryBot.create(:stored_file, name: "File4", with_tags: ["Tag2", "Tag3", "Tag4", "Tag5"])
      FactoryBot.create(:stored_file, name: "File5", with_tags: ["Tag3", "Tag4"])
    end

    context "query with only inclusive tags" do
      it "returns the structured information of files that contain all the include tags" do
        get "/files/+Tag3%20+Tag5/1"

        # Make sure the response has the right parameters
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)

        # Build up the json response
        _json_response = JSON.parse(response.body)

        # Verify its structure and expected results
        expect(_json_response["total_records"]).to eq(3)
        expect(_json_response["related_tags"]).to match_array([
          {"tag"=> "Tag1", "file_count" => 1},
          {"tag"=> "Tag2", "file_count" => 3},
          {"tag"=> "Tag4", "file_count" => 1}
        ])
        expect(_json_response["records"]).to match_array([
          {"uuid" => StoredFile.find_by_name("File4").id, "name" => "File4"},
          {"uuid" => StoredFile.find_by_name("File1").id, "name" => "File1"},
          {"uuid"=> StoredFile.find_by_name("File3").id, "name" => "File3"}
        ])
      end
    end

    context "query with only exclusive tags" do
      it "returns the structured information of files that do not contain any of the exclude tags" do
        get "/files/-Tag1%20-Tag2/1"

        # Make sure the response has the right parameters
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)

        # Build up the json response
        _json_response = JSON.parse(response.body)

        # Verify its structure and expected results
        expect(_json_response["total_records"]).to eq(1)
        expect(_json_response["related_tags"]).to match_array([
          {"tag"=> "Tag3", "file_count" => 1},
          {"tag"=> "Tag4", "file_count" => 1}
        ])
        expect(_json_response["records"]).to match_array([
          {"uuid"=> StoredFile.find_by_name("File5").id, "name" => "File5"}
        ])
      end
    end

    context "query with inclusive and exclusive tags" do
      it "returns the structured information of files that contain all the include tags and do not contain any of the exclude tags" do
        get "/files/+Tag2%20+Tag3%20-Tag4/1"

        # Make sure the response has the right parameters
        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)

        # Build up the json response
        _json_response = JSON.parse(response.body)

        # Verify its structure and expected results
        expect(_json_response["total_records"]).to eq(2)
        expect(_json_response["related_tags"]).to match_array([
          {"tag"=> "Tag1", "file_count" => 1},
          {"tag"=> "Tag5", "file_count" => 2}
        ])
        expect(_json_response["records"]).to match_array([
          {"uuid"=> StoredFile.find_by_name("File3").id, "name" => "File3"},
          {"uuid"=> StoredFile.find_by_name("File1").id, "name" => "File1"}
        ])
      end
    end
  end
end
