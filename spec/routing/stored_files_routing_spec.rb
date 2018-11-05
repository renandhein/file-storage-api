require "rails_helper"

RSpec.describe StoredFilesController, type: :routing do
  describe "routing" do
    it "routes to #file" do
      expect(:post => "/file").to route_to("stored_files#file")
    end
  end
end
