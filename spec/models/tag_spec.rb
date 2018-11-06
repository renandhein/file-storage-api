require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) {FactoryBot.create(:tag)}

  describe "validations" do
    it "is valid with factory attributes" do
      expect(tag).to be_valid
    end

    it "is not valid with a name over 100 characters" do
      _tag = FactoryBot.build(:tag, name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies, neque venenatis portaa.") #101 characters
      expect(_tag).to_not be_valid
    end

    it "is not valid with a name containing the '-', '+' or whitespace characters" do
      _tag = FactoryBot.build(:tag, name: "tes+t")
      expect(_tag).to_not be_valid

      _tag.name = "tes-t"
      expect(_tag).to_not be_valid

      _tag.name = "tes t"
      expect(_tag).to_not be_valid
    end
  end
end
