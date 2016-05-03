require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, created_by: @user
  end

  describe 'validations' do
    it 'can be valid' do
      assert @patient.valid?
    end

    it 'requires a name' do
      @patient.name = nil
      refute @patient.valid?
    end

    it 'requires a primary phone' do
      @patient.primary_phone = nil
      refute @patient.valid?
    end

    # it 'requires a logged creating user' do
      # @patient.created_by = nil
      # refute @patient.valid?
    # end
  end

  describe 'relationships' do
    it 'should have at least one associated pregnancy' do
    end

    it 'should have only one active pregnancy' do
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @patient.respond_to? field
        assert @patient[field]
      end
    end

    it 'should respond to history methods' do
      assert @patient.respond_to? :history_tracks
      assert @patient.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @patient.respond_to? :created_by
      assert @patient.created_by
    end
  end
end
