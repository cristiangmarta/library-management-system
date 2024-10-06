RSpec.shared_context 'when user is not logged in' do
  its(:status) { is_expected.to eq status_code(:unauthorized) }
end
