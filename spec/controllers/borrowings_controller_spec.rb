
require 'rails_helper'

RSpec.describe Api::BorrowingsController, type: :controller do
  render_views

  let(:member) { create(:user) }
  let(:librarian) { create(:user, :librarian) }
  let (:params) { {} }

  describe 'GET index' do
    let!(:borrowing_1) { create(:borrowing) }
    let!(:borrowing_2) { create(:borrowing, user: member) }
    let!(:borrowing_3) { create(:borrowing, user: librarian) }

    subject { get :index, params: params }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      context 'returns scoped borrowings' do
        its(:status) { is_expected.to eq status_code(:ok) }
        its(:parsed_body) { is_expected.to eq [ borrowing_2.as_json ] }
      end
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      context 'returns all borrowings' do
        its(:status) { is_expected.to eq status_code(:ok) }
        its(:parsed_body) { is_expected.to eq Borrowing.all.as_json }
      end
    end
  end

  describe 'POST create' do
    let(:book) { create(:book) }
    subject { post :create, params: params }
    let(:params) { { borrowing: { book_id: book.id } } }

    include_context 'when user is not logged in'

    context 'when user is logged in' do
      before { sign_in member }

      context 'and the book is available' do
        it { expect { subject }.to change { Book.count }.by 1 }
        its(:status) { is_expected.to eq status_code(:created) }
      end

      context 'and the book is not available' do
        before { create_list(:borrowing, book.total_copies, book:) }
        it { expect { subject }.not_to change { Book.count } }
        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
      end

      context 'book was already borrowed by the user' do
        before { create(:borrowing, book:, user: member) }
        it { expect { subject }.not_to change { Book.count } }
        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
      end
    end
  end

  describe 'GET show' do
    subject { get :show, params: params }

    let(:borrowing) { create(:borrowing) }
    let(:params) { { id: borrowing.id } }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      context 'can not view other users borrowings' do
        its(:status) { is_expected.to eq status_code(:not_found) }
      end

      context 'can view its borrowings' do
        let(:borrowing) { create(:borrowing, user: member) }

        its(:status) { is_expected.to eq status_code(:ok) }
        its(:parsed_body) { is_expected.to eq borrowing.as_json }
      end
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      context 'can view all borrowings' do
        its(:status) { is_expected.to eq status_code(:ok) }
        its(:parsed_body) { is_expected.to eq borrowing.as_json }
      end
    end
  end

  describe 'POST return' do
    let(:borrowing) { create(:borrowing) }
    subject { post :return, params: params }
    let(:params) { { id: borrowing.id } }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      context 'can not return other user books' do
        its(:status) { is_expected.to eq status_code(:not_found) }
      end

      context 'book pending return' do
        let(:borrowing) { create(:borrowing, user: member) }

        its(:status) { is_expected.to eq status_code(:ok) }
        it { expect { subject }.to change { borrowing.reload.state }.to Borrowing::States::RETURNED }
      end

      context 'book already returned' do
        let(:borrowing) { create(:borrowing, :returned, user: member) }

        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
        it { expect { subject }.not_to change { borrowing.reload } }
      end
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      context 'can mark other member books as returned' do
        its(:status) { is_expected.to eq status_code(:ok) }
        it { expect { subject }.to change { borrowing.reload.state }.to Borrowing::States::RETURNED }
      end
    end
  end
end
