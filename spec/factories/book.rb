FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    sequence(:isbn) { |n| "978-1-#{"%05d" % n}-000-4" }

    total_copies { 5 }
  end
end
