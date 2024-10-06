class UserRole < ApplicationRecord
  class << self
    def role_configuration
      @role_configuration ||= configuration_content["roles"]
    end

    private

    def configuration_content
      YAML.load_file(Rails.root.join("config/user_roles.yml"))
    end
  end

  module Roles
    UserRole.role_configuration.each_key do |role|
      const_set(role.upcase, role)
    end

    ALL = Utils.all_constants_in(self)
  end

  belongs_to :user

  validates :role, presence: true, inclusion: { in: Roles::ALL }
end
