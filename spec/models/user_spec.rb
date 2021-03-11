require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { expect belong_to(:project).optional }
    it { expect belong_to(:department).optional }
    it { expect belong_to(:location).optional }
  end

  describe 'validations' do
    it { expect validate_presence_of(:first_name) }
    it { expect validate_presence_of(:last_name) }
    it { expect validate_presence_of(:email) }
    it { expect validate_presence_of(:project_id) }

    context 'uniqueness' do
      subject { create(:user) }
      it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
      it { is_expected.to validate_uniqueness_of(:github).ignoring_case_sensitivity.allow_nil }
    end
  end

  describe 'delegates' do
    it { expect delegate_method(:name).to(:department).with_prefix(:department).allow_nil }
    it { expect delegate_method(:name).to(:project).with_prefix(:project).allow_nil }
    it { expect delegate_method(:name).to(:location).with_prefix(:location).allow_nil }
  end

  describe 'methods' do
    it 'full_name' do
      user = build(:user, first_name: 'aaa', last_name: 'bbb')
      expect(user.full_name).to eq('aaa bbb')
    end
  end
end
