require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

    @patient2 = create :patient, other_phone: '333-222-3333',
                                other_contact: 'Foobar'
    @call = create :call, patient: @patient,
                          status: 'Reached patient'
    create_language_config
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

    it 'should init a fulfillment after creation' do
      assert_nil @new_patient.fulfillment
      @new_patient.save
      @new_patient.reload
      refute_nil @new_patient.fulfillment
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

    it 'should save the identifer' do
      assert_equal @patient.identifier, "#{@patient.line[0]}#{@patient.primary_phone[-5]}-#{@patient.primary_phone[-4..-1]}"
    end
  end

  describe 'pledge_summary' do
    # TODO: needs timecopping
    it "should return proper pledge summaries for various timespans" do
      @patient.update appointment_date: (Date.today + 4), fund_pledge: 300
      @patient2.update appointment_date: (Date.today + 8), fund_pledge: 500, pledge_sent: true
      assert_equal '{:pledged=>0, :sent=>0}', Patient.pledged_status_summary(1).to_s
      assert_equal '{:pledged=>300, :sent=>0}', Patient.pledged_status_summary.to_s
      # TODO Timecop this test
      # assert_equal '{:pledged=>300, :sent=>500}', Patient.pledged_status_summary(10).to_s
    end
  end

  describe 'callbacks' do
    describe 'clean_fields' do
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

    describe 'confirm still urgent' do
      before do
        create :clinic
        @patient = create :patient, urgent_flag: true,
                                    clinic: Clinic.first,
                                    appointment_date: 2.days.from_now,
                                    fund_pledge: 300
      end

      %w[pledge_sent resolved_without_fund].each do |attrib|
        it "should unmark urgent after update if #{attrib}" do
          @patient[attrib.to_sym] = true
          @patient.save

          refute @patient.urgent_flag
        end
      end
    end
  end

  describe 'search method' do
    before do
      @pt_1 = create :patient, name: 'Susan Sher',
                               primary_phone: '124-456-6789'
      @pt_2 = create :patient, name: 'Susan E',
                               primary_phone: '124-567-7890',
                               other_contact: 'Friend Ship'
      @pt_3 = create :patient, name: 'Susan A',
                               primary_phone: '555-555-5555',
                               other_phone: '999-999-9999'
      @pt_4 = create :patient, name: 'Susan A in MD',
                               primary_phone: '777-777-7777',
                               other_phone: '999-111-9888',
                               line: 'MD'
    end

    it 'should find a patient on name or other name' do
      assert_equal 1, Patient.search('Susan Sher').count
      assert_equal 1, Patient.search('Friend Ship').count
    end

    it 'can find multiple patients off an identifier' do
      assert_same_elements [@pt_1, @pt_2], Patient.search('D1-24')
    end

    # it 'should find multiple patients if there are multiple' do
    #   assert_equal 2, Patient.search('124-456-6789').count
    # end

    describe 'order' do
      before do
        Timecop.freeze Date.new(2014,4,4)
        @pt_4.update! name: 'Laila C.'
        Timecop.freeze Date.new(2014,4,5)
        @pt_3.update! name: 'Laila B.'
      end

      after do
        Timecop.return
      end

      it 'should return patients in order of last modified' do
        assert_equal [@pt_3, @pt_4], Patient.search('Laila')
      end

      it 'should limit the number of patients returned' do
        16.times do |num|
          create :patient, primary_phone: "124-567-78#{num+10}"
        end
        assert_equal 15, Patient.search('124').count
      end
    end

    it 'should be able to find based on secondary phones too' do
      assert_equal 1, Patient.search('999-999-9999').count
    end

    # spotty test?
    it 'should be able to find based on phone patterns' do
      assert_equal 2, Patient.search('124').count
    end

    it 'should be able to narrow on line' do
      assert_equal 2, Patient.search('Susan A').count
      assert_equal 1, Patient.search('Susan A', 'MD').count
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

  describe 'scopes' do
    before do
      # DC patients created in initial before block
      create :patient, line: 'MD'
      create :patient, line: 'VA'
    end

    it 'should allow scoping for each line' do
      assert_equal 2, Patient.dc.count
      assert_equal 1, Patient.va.count
      assert_equal 1, Patient.md.count
    end
  end

  describe 'methods' do
    describe 'urgent patients class method' do
      before do
        create :patient
        2.times { create :patient, urgent_flag: true }
        create :patient, urgent_flag: true, line: 'MD'
      end

      it 'should return urgent patients' do
        assert_equal 3, Patient.urgent_patients.count
      end

      it 'should scope to a line if asked' do
        assert_equal 2, Patient.urgent_patients('DC').count
        assert_equal 1, Patient.urgent_patients('MD').count
      end
    end

    describe 'saving identifier method' do
      it 'should return a identifier' do
        @patient.update primary_phone: '111-333-5555'
        assert_equal 'D3-5555', @patient.save_identifier
      end
    end

    describe 'most_recent_note_display_text method' do
      before do
        @note = create :note, patient: @patient,
                              full_text: (1..100).map(&:to_s).join('')
      end

      it 'returns 34 characters of the notes text' do
        assert_equal 34, @patient.most_recent_note_display_text.length
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

    describe 'still urgent method' do
      it 'should return true if marked urgent in last 6 days' do
        @patient.update urgent_flag: true
        assert @patient.still_urgent?
      end

      it 'should return false if pledge sent' do
        @patient.update urgent_flag: true
        @patient.update pledge_sent: true
        assert_not @patient.still_urgent?
      end

      it 'should return false if resolved without fund' do
        @patient.update urgent_flag: true
        @patient.update resolved_without_fund: true
        assert_not @patient.still_urgent?
      end

      it 'should return false if not updated for more than 6 days' do
        Timecop.freeze(Time.zone.now - 7.days) do
          @patient.update urgent_flag: true
        end

        assert_not @patient.still_urgent?
      end
    end

    describe 'contacted_since method' do
      it 'should return a hash' do
        datetime = 5.days.ago
        hash = { since: datetime, contacts: 1, first_contacts: 1, pledges_sent: 20 }
        assert_equal hash, Patient.contacted_since(datetime)
      end
    end

    describe 'no_contact_since method' do
      it 'should return a hash' do
        datetime = 5.days.ago
        hash = { since: datetime, contacts: 1, first_contacts: 1, pledges_sent: 20 }
        assert_equal hash, Patient.contacted_since(datetime)
      end
    end

    describe 'fulfilled_on_or_before method' do
      before do
        @fulfilled_patient = create :patient, other_phone: '404-222-3333',
                                  other_contact: 'Yolo',
                                  primary_phone: '909-333-4321',
                                  line: 'DC',
                                  name: 'Pat'
        @unfulfilled_patient = create :patient, other_phone: '234-222-3333',
                                  other_contact: 'Yolo',
                                  primary_phone: '909-333-4999',
                                  line: 'DC',
                                  name: 'Chelsea'
        @fulfilled_patient.update initial_call_date: 150.days.ago
        @fulfilled_patient.fulfillment.update date_of_check: 120.days.ago
      end

      it 'should be able to give me patients fulfilled on or before a day' do
        assert_equal 1, Patient.fulfilled_on_or_before(20.days.ago).count
      end
    end

    describe 'has_alt_contact method' do
      before do
        @lonely_patient = create :patient, primary_phone: '703-867-5319',
                                      line: 'DC',
                                      name: 'Mickey'
        @popular_patient_1 = create :patient, primary_phone: '703-867-5329',
                                      line: 'DC',
                                      name: 'Daffy',
                                      other_contact: 'Daisy'
        @popular_patient_2 = create :patient, primary_phone: '703-867-5339',
                                      line: 'DC',
                                      name: 'Lucy',
                                      other_phone: '802-212-1242'
        @popular_patient_3 = create :patient, primary_phone: '703-867-5359',
                                      line: 'DC',
                                      name: 'Chuck',
                                      other_contact_relationship: 'Mom'
      end

      it 'should return false for lonely patient' do
        refute @lonely_patient.has_alt_contact?
      end

      it 'should return true when patient has other contact' do
        refute @popular_patient_1.has_alt_contact?
      end

      it 'should return true when patient has other phone' do
        refute @popular_patient_2.has_alt_contact?
      end

      it 'should return true when patient has other contact relationship' do
        refute @popular_patient_3.has_alt_contact?
      end
    end #has_alt_contact

    describe 'set_age_range method' do
      before do
        @rapidly_aging_patient = create :patient, primary_phone: '703-867-5309',
                                      line: 'DC',
                                      name: 'Mickey'
      end

      it 'should return unknown for nil' do
        assert_equal :unknown, @rapidly_aging_patient.set_age_range
      end

      it 'should return unknown for empty' do
        @rapidly_aging_patient.age = ''
        assert_equal :unknown, @rapidly_aging_patient.set_age_range
      end

      it 'should return under_18 for 17' do
        @rapidly_aging_patient.age = 17
        assert_equal :under_18, @rapidly_aging_patient.set_age_range
      end

      it 'should return age18_24 for 21' do
        @rapidly_aging_patient.age = 21
        assert_equal :age18_24, @rapidly_aging_patient.set_age_range
      end

      it 'should return age25_34 for 33' do
        @rapidly_aging_patient.age = 33
        assert_equal :age25_34, @rapidly_aging_patient.set_age_range
      end

      it 'should return age35_44 for 38' do
        @rapidly_aging_patient.age = 38
        assert_equal :age35_44, @rapidly_aging_patient.set_age_range
      end

      it 'should return age45_54 for 49' do
        @rapidly_aging_patient.age = 49
        assert_equal :age45_54, @rapidly_aging_patient.set_age_range
      end

      it 'should return age55_100 for 60' do
        @rapidly_aging_patient.age = 60
        assert_equal :age55_100, @rapidly_aging_patient.set_age_range
      end

      it 'should return Bad value for 111' do
        @rapidly_aging_patient.age = 111
        assert_equal 'Bad value', @rapidly_aging_patient.set_age_range
      end
    end # set_age_range 
  end # methods

  describe 'pledge_sent validation' do
    before do
      @clinic = create :clinic
      @patient.fund_pledge = 500
      @patient.clinic = @clinic
      @patient.appointment_date = 14.days.from_now
    end

    it 'should validate pledge_sent when all items in #check_other_validations? are present' do
      @patient.pledge_sent = true
      assert @patient.valid?
    end

    it "should not validate pledge_sent if the #{FUND} pledge field is blank" do
      @patient.fund_pledge = nil
      @patient.pledge_sent = true
      refute @patient.valid?
      assert_equal ["DCAF pledge field cannot be blank"], @patient.errors.messages[:pledge_sent]
    end

    it 'should not validate pledge_sent if the clinic name is blank' do
      @patient.clinic = nil
      @patient.pledge_sent = true
      refute @patient.valid?
      assert_equal ['Clinic name cannot be blank'], @patient.errors.messages[:pledge_sent]
    end

    it 'should not validate pledge_sent if the appointment date is blank' do
      @patient.appointment_date = nil
      @patient.pledge_sent = true
      refute @patient.valid?
      assert_equal ['Appointment date cannot be blank'], @patient.errors.messages[:pledge_sent]
    end

    it 'should produce three error messages if three required fields are blank' do
      @patient.fund_pledge = nil
      @patient.clinic = nil
      @patient.appointment_date = nil
      @patient.pledge_sent = true
      refute @patient.valid?
      assert_equal ["DCAF pledge field cannot be blank", 'Clinic name cannot be blank', 'Appointment date cannot be blank'],
      @patient.errors.messages[:pledge_sent]
    end

    it 'should have convenience methods to render in view, just in case' do
      refute @patient.pledge_info_present?
      @patient.fund_pledge = nil
      assert @patient.pledge_info_present?
      assert_equal ["DCAF pledge field cannot be blank"], @patient.pledge_info_errors
    end
    
    it 'should update sent by and sent at when sending the pledge' do
      @user = create :user
      @patient.fund_pledge = 500
      @patient.clinic = @clinic
      @patient.appointment_date = 14.days.from_now
      @patient.last_edited_by = @user
      @patient.fund_pledge = true
      @patient.pledge_sent = true
      @patient.update
      @patient.reload
      assert_in_delta Time.zone.now.to_f, @patient.pledge_sent_at.to_f, 15 #used assert_in_delta to account for slight differences in timing. Allows 15 seconds of lag?
      assert_equal @user, @patient.pledge_sent_by
    end
    
    it 'should set pledge sent and sent at to nil if a pledge is cancelled' do
      @patient.pledge_sent = false
      @patient.update
      @patient.reload
      assert_nil @patient.pledge_sent_by
      assert_nil @patient.pledge_sent_at
    end
    
  end

  describe 'last menstrual period calculation concern' do
    before do
      @user = create :user
      @patient = create :patient, created_by: @user,
                                  initial_call_date: 2.days.ago,
                                  last_menstrual_period_weeks: 9,
                                  last_menstrual_period_days: 2,
                                  appointment_date: 2.days.from_now
    end

    describe 'last_menstrual_period_display' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.last_menstrual_period_display
      end

      it 'should return LMP in weeks and days' do
        assert_equal '9 weeks, 4 days',
                     @patient.last_menstrual_period_display
      end
    end

    describe 'last_menstrual_period_display_short' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.last_menstrual_period_display_short
      end

      it 'should return shorter LMP in weeks and days' do
        assert_equal @patient.last_menstrual_period_display_short, '9w 4d'
      end
    end

    describe 'last_menstrual_period_at_appt' do
      it 'should return nil unless appt date is set' do
        @patient.appointment_date = nil
        assert_nil @patient.last_menstrual_period_at_appt
      end

      it 'should return a calculated LMP on date of appointment' do
        assert_equal '9 weeks, 6 days',
                     @patient.last_menstrual_period_at_appt
      end
    end

    describe 'last_menstrual_period_now' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.send(:_last_menstrual_period_now)
      end

      it 'should be equivalent to LMP on date - Time.zone.today' do
        assert_equal  @patient.send(:_last_menstrual_period_now),
                      @patient.send(:_last_menstrual_period_on_date,
                                    Time.zone.today)
      end

      it 'should be LMP on date of appointment if appointment is in the past' do
        @patient.appointment_date = 1.day.ago
        assert_equal  @patient.send(:_last_menstrual_period_now),
                      @patient.send(:_last_menstrual_period_on_date, 1.day.ago.to_date)
      end
    end

    describe 'last_menstrual_period_on_date' do
      it 'should nil out if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.send(:_last_menstrual_period_on_date,
                                 Time.zone.today)
      end

      it 'should accurately calculate LMP on a given date' do
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 67
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   5.days.from_now.to_date), 72

        @patient.initial_call_date = 4.days.ago
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                    Time.zone.today), 69

        @patient.last_menstrual_period_weeks = 10
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 76

        @patient.last_menstrual_period_days = 6
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 80
      end

      it 'should cap at 280 days' do
        @patient.last_menstrual_period_weeks = 52
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 280
      end
    end

    describe '_display_as_weeks' do
      it 'should return a value of weeks and days' do
        assert_equal '3 weeks, 3 days', @patient.send(:_display_as_weeks, 24)
      end
    end
  end

  describe 'status concern methods' do
    before do
      @user = create :user
      @patient = create :patient, other_phone: '111-222-3333',
                                  other_contact: 'Yolo'
    end

    describe 'status method branch 1' do
      it 'should default to "No Contact Made" when a patient has no calls' do
        assert_equal Patient::STATUSES[:no_contact], @patient.status
      end

      it 'should default to "No Contact Made" on a patient left voicemail' do
        create :call, patient: @patient, status: 'Left voicemail'
        assert_equal Patient::STATUSES[:no_contact], @patient.status
      end

      it 'should still say "No Contact Made" if patient leaves voicemail with appointment' do
        @patient.appointment_date = '01/01/2017'
        assert_equal Patient::STATUSES[:no_contact], @patient.status
      end
    end

    describe 'status method branch 2' do
      it 'should update to "Needs Appointment" once patient has been reached' do
        create :call, patient: @patient, status: 'Reached patient'
        assert_equal Patient::STATUSES[:needs_appt], @patient.status
      end

      it 'should update to "Fundraising" once appointment made and patient reached' do
        create :call, patient: @patient, status: 'Reached patient'
        @patient.appointment_date = '01/01/2017'
        assert_equal Patient::STATUSES[:fundraising], @patient.status
      end

      it 'should update to "Sent Pledge" after a pledge has been sent' do
        @patient.pledge_sent = true
        assert_equal Patient::STATUSES[:pledge_sent], @patient.status
      end

      it 'should update to "Pledge Not Fulfilled" if a pledge has not been fulfilled for 150 days' do
        @patient.pledge_sent = true 
        @patient.pledge_sent_at = (Time.zone.now - 151.days)
        assert_equal Patient::STATUSES[:pledge_unfulfilled], @patient.status
      end

      it 'should update to "Pledge Fulfilled" if a pledge has been fulfilled' do
        @patient.fulfillment.fulfilled = true
        assert_equal Patient::STATUSES[:fulfilled], @patient.status
      end

      # it 'should update to "Pledge Paid" after a pledge has been paid' do
      # end
      it 'should update to "No contact in 120 days" after 120ish days of no calls' do
        create :call, patient: @patient, status: 'Reached patient', created_at: 121.days.ago
        assert_equal Patient::STATUSES[:dropoff], @patient.status

        create :call, patient: @patient, status: 'Left voicemail', created_at: 120.days.ago
        assert_equal Patient::STATUSES[:needs_appt], @patient.status
      end

      it 'should update to "Resolved Without DCAF" if patient is resolved' do
        @patient.resolved_without_fund = true
        assert_equal Patient::STATUSES[:resolved], @patient.status
      end
    end

    describe 'contact_made? method' do
      it 'should return false if no calls have been made' do
        refute @patient.send :contact_made?
      end

      it 'should return false if an unsuccessful call has been made' do
        create :call, patient: @patient, status: 'Left voicemail'
        refute @patient.send :contact_made?
      end

      it 'should return true if a successful call has been made' do
        create :call, patient: @patient, status: 'Reached patient'
        assert @patient.send :contact_made?
      end
    end
  end

  describe 'patient archive scopes' do
    before do
      @pt1 = create :patient, other_phone: '111-222-3333',
                                  other_contact: 'Yolo',
                                  primary_phone: '222-333-4321',
                                  name: 'Archiveworthy'

      @pt2 = create :patient, other_phone: '111-222-3933',
                                  other_contact: 'Yolo',
                                  primary_phone: '222-033-4321',
                                  name: 'Archiveworthy'
      @pt2.archive!
    end

#    it 'should see that there are archived and unarchived patients' do
#      @pt1.reload
#      @pt2.reload
#      assert_equal 1, Patient.is_archived.count
#      assert_equal 1, Patient.unarchived.count
#    end
  end

  describe 'archive tests' do
    before do
      @old_fulfill_patient = create :patient, other_phone: '111-222-3333',
                                  other_contact: 'Yolo',
                                  primary_phone: '222-333-4321',
                                  name: 'Archiveworthy',
                                  special_circumstances: ["Prison", "Fetal anomaly"],
                                  line: 'DC'

      @old_fulfill_patient.update initial_call_date: 150.days.ago
      @old_fulfill_patient.fulfillment.update date_of_check: 120.days.ago,
                                              check_number: 1337
      create :call, patient: @old_fulfill_patient, status: 'Reached patient', created_at: 142.days.ago
      create :note, patient: @old_fulfill_patient, full_text: (1..100).map(&:to_s).join('')
      @user = create :user
      create :external_pledge, patient: @old_fulfill_patient, created_by: @user
      @dropoff_patient = create :patient, other_phone: '111-222-3233',
                                  other_contact: 'Yolo',
                                  primary_phone: '222-333-4325',
                                  name: 'Archiveworthy'
      @dropoff_patient.update initial_call_date: 2.years.ago

      @active_patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

      @active_patient.update initial_call_date: 2.days.ago
      Patient.archive
      #@old_fulfill_patient.archive!
      @old_fulfill_patient.reload
      @dropoff_patient.reload
      @active_patient.reload
      #puts "BAZRAZ" + @old_fulfill_patient.inspect.to_s
    end

    describe 'archived status tests' do
      it 'should report not archived for active patients' do
        assert_not @active_patient.archived?
      end

      it 'should report archived for archived patients' do
        assert @old_fulfill_patient.archived?
        assert @dropoff_patient.archived?
      end

      it 'should not have a phone number' do
        assert_not @old_fulfill_patient.primary_phone
      end
      it 'should not have a name' do
        assert_equal "ARCHIVED", @old_fulfill_patient.name
      end
      it 'should not have any notes' do
        @old_fulfill_patient.notes.each do |note|
          assert_equal "ARCHIVED", note.full_text
        end
      end
      it 'should not have an age' do
        assert_not @old_fulfill_patient.age
      end
      it 'should have an age_range' do
        assert @old_fulfill_patient.age_range
      end
      it 'should not have an other contact name' do
        assert_not @old_fulfill_patient.other_contact
      end
      it 'should not have an other contact number' do
        assert_not @old_fulfill_patient.other_phone
      end
      it 'should not have an other contact relationship' do
        assert_not @old_fulfill_patient.other_contact_relationship
      end
      it 'should not have any circumstances' do
        assert_equal [], @old_fulfill_patient.special_circumstances
      end
      it 'should not have a check # on pledges' do
        assert_not @old_fulfill_patient.fulfillment.check_number
      end
      it 'should have a UUID based ID' do
        assert_match  /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, @old_fulfill_patient.identifier
      end

      it 'should archive on direct archive call' do
        @archive_direct = create :patient, other_phone: '111-222-2333',
                                    other_contact: 'Yolo',
                                    primary_phone: '222-333-4325',
                                    name: 'Archiveworthy'
        @archive_direct.update initial_call_date: 2.years.ago
        @archive_direct.archive!
        @archive_direct.reload

        assert @archive_direct.archived?
      end
    end

    # TODO test dropoff patients
   # describe 'archived status readonly' do
   #   it 'should not allow updates to archived patients' do
   #     flunk("IOU")
   #     # TODO integration test for this as well?
   #   end
   # end
  end

  describe 'export concern methods' do
    before { @patient = create :patient }

    describe 'age range tests' do
      it 'should return the right age for numbers' do
        @patient.age = nil
        assert_nil @patient.get_age_range

        [15, 17].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, 'Under 18'
        end

        [18, 20, 24].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, '18-24'
        end

        [25, 30, 34].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, '25-34'
        end

        [35, 40, 44].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, '35-44'
        end

        [45, 50, 54].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, '45-54'
        end

        [55, 60, 100].each do |age|
          @patient.update age: age
          assert_equal @patient.get_age_range, '55+'
        end

        [101, 'yolo'].each do |bad_age|
          @patient.age = bad_age
          assert_equal @patient.get_age_range, 'Bad value'
        end
      end
    end

    describe 'preferred language tests' do
      it 'should return the right language' do
        ['', nil].each do |language|
          @patient.update language: language
          assert_equal @patient.preferred_language, 'English'
        end

        @patient.language = 'Spanish'
          assert_equal @patient.preferred_language, 'Spanish'
      end
    end
  end
end
