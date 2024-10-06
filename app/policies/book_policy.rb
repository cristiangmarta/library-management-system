class BookPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def manage?
    user.librarian?
  end
end
