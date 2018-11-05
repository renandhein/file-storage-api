require 'rails_helper'

RSpec.describe StoredFile, type: :model do
  let(:stored_file) {FactoryBot.create(:stored_file)}

  describe "validations" do
    it "is valid with factory attributes" do
      expect(stored_file).to be_valid
    end

    it "is not valid with a name over 100 characters" do
      _stored_file = FactoryBot.build(:stored_file, name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies, neque venenatis portaa.") #101 characters
      expect(_stored_file).to_not be_valid
    end
  end
end
