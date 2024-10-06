class Borrowing < ApplicationRecord
  module States
    PENDING = "pending".freeze
    RETURNED = "returned".freeze

    ALL = Utils.all_constants_in(self)
  end

  belongs_to :user
  belongs_to :book

  validates :user, :book, presence: true
  validates :due_by, presence: true, on: :update
  validates :user_id, uniqueness: { scope: :book_id, message: "book already borrowed" }
  validate on: :create do
    errors.add(:book, "unavailable") unless book&.available?
  end

  state_machine initial: States::PENDING do
    event :mark_returned do
      transition from: States::PENDING, to: States::RETURNED
    end
  end

  before_create do
    assign_attributes(due_by: 2.weeks.from_now)
  end
end
