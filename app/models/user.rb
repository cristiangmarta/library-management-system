class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Roleable

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :borrowings, dependent: :delete_all

  validates :email, uniqueness: true
end
