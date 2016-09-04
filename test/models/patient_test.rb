require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'
    @pregnancy = create :pregnancy, patient: @patient
  end

  describe 'callbacks' do
    before do
      @new_patient = build :patient, name: '  Name With Whitespace  ',
                                     other_contact: '  name with whitespace ',
                                     other_contact_relationship: '  something ',
                                     primary_phone: '111-222-3333',
                                     other_phone: '999-888-7777'
    end

    it 'should clean fields before save' do
      @new_patient.save
      assert_equal 'Name With Whitespace', @new_patient.name
      assert_equal 'name with whitespace', @new_patient.other_contact
      assert_equal 'something', @new_patient.other_contact_relationship
      assert_equal '1112223333', @new_patient.primary_phone
      assert_equal '9998887777', @new_patient.other_phone
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

    %w(initial_call_date name primary_phone created_by).each do |field|
      it "should enforce presence of #{field}" do
        @patient[field.to_sym] = nil
        refute @patient.valid?
      end
    end

    it 'should require appointment_date to be after initial_call_date' do
      @patient.initial_call_date = '2016-06-01'
      @patient.appointment_date = '2016-05-01'
      refute @patient.valid?
      @patient.appointment_date = nil
      assert @patient.valid?
      @patient.appointment_date = '2016-07-01'
      assert @patient.valid?
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

  #   it 'should have at least one associated patient' do
  #   end

  #   it 'should have only one active patient' do
  #   end
  # end

  describe 'search method' do
    before do
      @pt_1 = create :patient, name: 'Susan Sher', primary_phone: '124-456-6789'
      @pt_2 = create :patient, name: 'Susan E',
                               primary_phone: '124-567-7890',
                               other_contact: 'Friend Ship'
      @pt_3 = create :patient, name: 'Susan A', other_phone: '999-999-9999'
      [@pt_1, @pt_2, @pt_3].each do |pt|
        create :pregnancy, patient: pt, created_by: @user
      end
    end

    it 'should find a patient on name or other name' do
      assert_equal 1, Patient.search('Susan Sher').count
      assert_equal 1, Patient.search('Friend Ship').count
    end

    # it 'should find multiple patients if there are multiple' do
    #   assert_equal 2, Patient.search('124-456-6789').count
    # end

    it 'should be able to find based on secondary phones too' do
      assert_equal 1, Patient.search('999-999-9999').count
    end

    it 'should be able to find based on phone patterns' do
      assert_equal 2, Patient.search('124').count
    end

    it 'should not choke if it does not find anything' do
      assert_equal 0, Patient.search('no entries with this').count
    end
  end

  describe 'other methods' do
    before do
      @patient = create :patient, primary_phone: '111-222-3333',
                                  other_phone: '111-222-4444'
    end

    it 'primary_phone_display -- should be hyphenated phone' do
      refute_equal @patient.primary_phone, @patient.primary_phone_display
      assert_equal '111-222-3333', @patient.primary_phone_display
    end

    it 'secondary_phone_display - should be hyphenated other phone' do
      refute_equal @patient.other_phone, @patient.other_phone_display
      assert_equal '111-222-4444', @patient.other_phone_display
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

  describe 'methods' do
    describe 'identifier method' do
      it 'should return a identifier' do
        @patient.update primary_phone: '111-333-5555'
        assert_equal 'D3-5555', @patient.identifier
      end
    end

    describe 'most_recent_note_display_text method' do
      before do
        @note = create :note, patient: @patient,
                              full_text: (1..100).map(&:to_s).join('')
      end

      it 'returns 44 characters of the notes text' do
        assert_equal 44, @patient.most_recent_note_display_text.length
        assert_match /^1234/, @patient.most_recent_note_display_text
      end
    end

    describe 'history check methods' do
      it 'should say whether a patient is still urgent' do
        # TODO: TIMECOP
        @patient.urgent_flag = true
        @patient.save

        assert @patient.still_urgent?
      end

      it 'should trim pregnancies after they have been urgent for five days' do
        # TODO: TEST patient#trim_urgent_pregnancies
      end
    end
  end
end
