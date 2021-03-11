require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'associations' do
    it { expect belong_to(:project) }
    it { expect belong_to(:service) }
  end

  describe 'validations' do
    it { expect validate_presence_of(:project_id) }
    it { expect validate_presence_of(:service_id) }

    context 'uniqueness' do
      subject { create(:setting) }
      it { is_expected.to validate_uniqueness_of(:project_id).scoped_to(:service_id) }
    end

    context 'json value' do
      it 'with empty string' do
        expect(build(:setting, value: '')).to_not be_valid
      end

      it 'with empty brackets' do
        expect(build(:setting, value: '{}')).to_not be_valid
      end

      it 'with invalid json' do
        expect(build(:setting, value: '{ abc }')).to_not be_valid
      end

      it 'with valid json' do
        expect(build(:setting, value: '{ "valid": "abc" }')).to be_valid
      end
    end
  end
end
