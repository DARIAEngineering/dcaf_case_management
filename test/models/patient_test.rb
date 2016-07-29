require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'
  end

  describe 'callbacks' do
    before do
      @new_patient = build :patient, primary_phone: '111-222-3333',
                                     other_phone: '999-888-7777'
    end

    it 'should clean phones before save' do
      assert_equal '111-222-3333', @new_patient.primary_phone
      assert_equal '999-888-7777', @new_patient.other_phone
      @new_patient.save
    end
  end

  describe 'validations' do
    it 'should build' do
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

    it 'requires a logged creating user' do
      @patient.created_by_id = nil
      refute @patient.valid?
    end

    %w(primary_phone other_phone).each do |phone|
      it "should enforce a max length of 10 for #{phone}" do
        @patient[phone] = '123-456-789022'
        refute @patient.valid?
      end

      it "should clean before validation for #{phone}" do
        @patient[phone] = '111-222-3333'
        @patient.save
        assert_equal '1112223333', @patient[phone]
      end
    end
  end

  describe 'callbacks' do
    %w(name other_contact).each do |field|
      it "should strip whitespace from before and after #{field}" do
        @patient[field] = '   Yolo Goat   '
        @patient.save
        assert_equal 'Yolo Goat', @patient[field]
      end
    end

    %w(primary_phone other_phone).each do |field|
      it "should remove nondigits on save from #{field}" do
        @patient[field] = '111-222-3333'
        @patient.save
        assert_equal '1112223333', @patient[field]
      end
    end
  end

  # describe 'relationships' do
  #   it 'should have many pregnancies' do
  #   end

  #   it 'should have at least one associated pregnancy' do
  #   end

  #   it 'should have only one active pregnancy' do
  #   end
  # end

  describe 'search method' do
    before do
      @pt_1 = create :patient, name: 'Susan Sher', primary_phone: '124-456-6789'
      @pt_2 = create :patient, name: 'Susan E',
                               primary_phone: '124-456-6789',
                               other_contact: 'Friend Ship'
      @pt_3 = create :patient, name: 'Susan A', other_phone: '999-999-9999'
      [@pt_1, @pt_2, @pt_3].each do |pt|
        create :pregnancy, patient: pt, created_by: @user
      end
    end

    it 'should find a patient on name or other name' do
      # these two tests are failing because the search function is stripping to an empty string on phone, and then in effect performing a wildcard search

      assert_equal 1, Patient.search('Susan Sher').count
      assert_equal 1, Patient.search('Friend Ship').count
    end

    it 'should find multiple patients if there are multiple' do
      assert_equal 2, Patient.search('124-456-6789').count
    end

    it 'should be able to find based on secondary phones too' do
      assert_equal 1, Patient.search('999-999-9999').count
    end

    it 'should be able to find based on phone patterns' do
      assert_equal 2, Patient.search('124').count
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
