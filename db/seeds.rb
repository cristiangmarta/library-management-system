# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#

FactoryBot.create_list(:user, 10, password: '1234Face')
FactoryBot.create_list(:user, 10, :librarian, password: '1234Face')

FactoryBot.create_list(:book, 100, total_copies: 3)

User.all.each do |user|
  book_ids = Book.includes(:pending_borrowings).select(&:available?).map(&:id).sample(rand(20))

  Borrowing.import([ :user_id, :book_id, :state, :due_by ], book_ids.map { |book_id| [ user.id, book_id, Borrowing::States::PENDING, rand(15).days.from_now ] }, validate: false)
end
