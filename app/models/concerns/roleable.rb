module Roleable
  extend ActiveSupport::Concern

  included do
    const_set(:Roles, UserRole::Roles) unless const_defined?(:Roles)

    has_many :user_roles, dependent: :delete_all

    UserRole::Roles::ALL.each do |role|
      meth = role.downcase
      define_method("#{meth}?") { role?(role) } unless method_defined?("#{meth}?")
    end
  end

  def roles_set
    @roles_set ||= user_roles.map(&:role).to_set
  end

  def role?(role)
    roles_set.include?(role)
  end

  def any_role?(*roles)
    roles.any? { |role| role?(role) }
  end

  def assign_roles(roles)
    roles = Array(roles) & User::Roles::ALL
    if roles_set != roles.to_set
      add_roles(roles)
      remove_roles(User::Roles::ALL - roles)
      reset_roles_cache
    end
    self
  end

  private

  def reset_roles_cache
    user_roles.reset
    @roles_set = nil
  end

  def add_roles(roles)
    if roles.present?
      data = roles.map { |role| { user_id: id, role: role } }
      UserRole.import(data, validate: false, on_duplicate_key_ignore: true)
    end
  end

  def remove_roles(roles)
    user_roles.where(role: roles).destroy_all if roles.present?
  end
end
