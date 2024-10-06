require 'rails_helper'

RSpec.describe Api::BooksController, type: :controller do
  render_views

  let(:member) { create(:user) }
  let(:librarian) { create(:user, :librarian) }
  let (:params) { {} }

  describe 'GET index' do
    subject { get :index, params: params }

    before { create_list(:book, 3) }

    include_context 'when user is not logged in'

    context 'when user is logged in' do
      before { sign_in member }

      its(:status) { is_expected.to eq status_code(:ok) }
      its(:parsed_body) { is_expected.to eq Book.all.as_json }

      context 'with a filter provided' do
        let (:params) { { filter: } }

        context 'and it does not match anything' do
          let (:filter) { "AAAAA" }

          its(:status) { is_expected.to eq status_code(:ok) }
          its(:parsed_body) { is_expected.to eq([]) }
        end

        context 'and it matches' do
          let(:book) { Book.all.sample }
          let (:filter) { book.send([ :title, :author, :genre ].sample).slice(0..2) }


          its(:status) { is_expected.to eq status_code(:ok) }
          its(:parsed_body) { is_expected.to include(book.as_json) }
        end
      end
    end
  end

  describe 'POST create' do
    subject { post :create, params: params }
    let(:params) {
      { book: {
        title: "book title 0",
        author: "author 0",
        genre: "genre 0",
        isbn: "978-3-16-148410-0",
        total_copies:
      } }
    }

    let(:total_copies) { 4 }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      its(:status) { is_expected.to eq status_code(:forbidden) }
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      it { expect { subject }.to change { Book.count }.by 1 }
      its(:status) { is_expected.to eq status_code(:created) }

      context 'with invalid values' do
        let(:total_copies) { -1 }
        it { expect { subject }.not_to change { Book.count } }
        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
      end
    end
  end

  describe 'GET show' do
    subject { get :show, params: params }

    let(:book) { create(:book) }
    let(:params) { { id: book.id } }

    include_context 'when user is not logged in'

    context 'when user is logged in' do
      before { sign_in member }

      context 'with an existing book id' do
        its(:status) { is_expected.to eq status_code(:ok) }
        its(:parsed_body) { is_expected.to eq book.as_json }
      end

      context 'with an invalid book id' do
        let(:params) { { id: 999 } }
        its(:status) { is_expected.to eq status_code(:not_found) }
      end
    end
  end

  describe 'PATCH update' do
    let!(:book) { create(:book) }
    let(:params) { { id: book.id, book: { author: } } }
    let(:author) { 'George RR' }

    subject { patch :update, params: params }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      its(:status) { is_expected.to eq status_code(:forbidden) }
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      it { expect { subject }.to change { book.reload.author }.to(author) }
      its(:status) { is_expected.to eq status_code(:ok) }

      context 'with invalid values' do
        let(:author) { '' }
        it { expect { subject }.not_to change { book.reload } }
        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:book) { create(:book) }
    let(:params) { { id: book.id } }

    subject { delete :destroy, params: params }

    include_context 'when user is not logged in'

    context 'when user is logged in as a member' do
      before { sign_in member }

      its(:status) { is_expected.to eq status_code(:forbidden) }
    end

    context 'when user is logged in as a librarian' do
      before { sign_in librarian }

      it { expect { subject }.to change { Book.count }.by(-1) }
      its(:status) { is_expected.to eq status_code(:no_content) }

      context 'some book copies already borrowed' do
        before { create(:borrowing, book:) }

        it { expect { subject }.not_to change { Book.count } }
        its(:status) { is_expected.to eq status_code(:unprocessable_entity) }
      end
    end
  end
end
