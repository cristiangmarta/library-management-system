require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe "Validations" do
    subject { build(:borrowing) }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:book) }
    it { is_expected.to validate_presence_of(:due_by).on(:update) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:book_id).with_message("book already borrowed") }
  end

  describe "Callbacks" do
    context "during creation, if due date was not set" do
      let(:borrowing) { build(:borrowing, due_by: nil) }
      it "sets it to 2 weeks from now" do
        borrowing.save
        expect(borrowing.due_by).to be_within(1.hour).of(borrowing.created_at + 2.weeks)
      end
    end
  end
end
