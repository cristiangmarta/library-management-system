FactoryBot.define do
  factory :borrowing do
    user
    book

    (Borrowing::States::ALL).each do |state|
      trait state.to_sym do
        state { state }
      end
    end
  end
end
