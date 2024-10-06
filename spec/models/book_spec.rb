require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:book) { create(:book) }

  describe "Validations" do
    subject { build(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:genre) }
    it { is_expected.to validate_presence_of(:total_copies) }

    it { is_expected.to validate_numericality_of(:total_copies).only_integer.is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_uniqueness_of(:isbn).case_insensitive }
    it { is_expected.to allow_value("978-1-56619-909-4").for(:isbn) }
    it { is_expected.not_to allow_value("55 65465 4513574").for(:isbn) }

    context 'with some copies are already borrowed' do
      before { create_list(:borrowing, book.total_copies - 1, book:) }

      context 'when the new value greater than or equal to the amount borrowed' do
        it 'is expected to be valid' do
          book.reload.total_copies -= 1
          expect(book.reload.valid?).to be true
        end
      end

      context 'when the new value is less than the amount borrowed' do
        it 'is expected to be invalid' do
          book.reload.total_copies -= 2
          expect(book.valid?).to be false
        end
      end
    end
  end

  describe "#available?" do
    before { create_list(:borrowing, number_borrowed, book:) }

    subject { book.reload.available? }

    context "when there are copies available" do
      let(:number_borrowed) { book.total_copies - 1 }

      it { is_expected.to be(true) }
    end

    context "when there isn't any available copy" do
      let(:number_borrowed) { book.total_copies }

      it { is_expected.to be(false) }
    end
  end
end
