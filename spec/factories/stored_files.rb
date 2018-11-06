FactoryBot.define do
  factory :stored_file do
    name { "text.txt" }

    transient do
      with_tags { [] }
    end

    after :create do |_stored_file, _options|
      _options.with_tags.each do |_tag_name|
        _stored_file.tags << (Tag.find_by_name(_tag_name) || create(:tag, name: _tag_name))
      end
    end
  end
end
