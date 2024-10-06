class BorrowingPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.librarian?
        scope.all
      else
        scope.where(user:)
      end
    end
  end

  def return?
    manage?
  end

  def manage?
    true
  end
end
