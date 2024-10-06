FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "admin-test-#{n}@example.com" }
    password { Faker::Internet.password }

    User::Roles::ALL.each do |role|
      trait role.downcase.to_sym do
        after(:create) do |user|
          user.user_roles.create(role: role)
        end
      end
    end
  end
end
