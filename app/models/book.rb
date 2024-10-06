class Book < ApplicationRecord
  ISBN_REGEX = /\A(?=(?:\D*\d){10}(?:(?:\D*\d){3})?$)[\d-]+\Z/.freeze

  has_many :borrowings, dependent: :restrict_with_error
  has_many :pending_borrowings, -> { with_state(Borrowing::States::PENDING) }, class_name: "Borrowing"

  validates :title, :author, :genre, :total_copies, presence: true
  validates :isbn, format: { with: ISBN_REGEX, message: "Invalid ISBN format" }, uniqueness: true
  validates :total_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate do
    if (total_copies_was > total_copies rescue nil)
      errors.add(:total_copies, "not enough copies") if pending_borrowings.size > total_copies
    end
  end

  def available?
    pending_borrowings.size < total_copies
  end
end
