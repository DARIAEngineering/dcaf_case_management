require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  extend Minitest::OptionalRetry

  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'

    @patient2 = create :patient, other_phone: '333-222-3333',
                                 other_contact: 'Foobar'
    with_versioning do
      PaperTrail.request(whodunnit: @user) do
        @patient.calls.create attributes_for(:call, status: :reached_patient)
      end
    end
    
    @call = @patient.calls.first
    create_language_config
  end

  describe 'callbacks' do
    before do
      @new_patient = build :patient, name: '  Name With Whitespace  ',
                                     other_contact: '  also name with whitespace ',
                                     other_contact_relationship: '  something ',
                                     primary_phone: '111-222-3333',
                                     other_phone: '999-888-7777'
    end

    it 'should clean fields before save' do
      @new_patient.save
      assert_equal 'Name With Whitespace', @new_patient.name
      assert_equal 'also name with whitespace', @new_patient.other_contact
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

    %w(initial_call_date name primary_phone).each do |field|
      it "should enforce presence of #{field}" do
        @patient[field.to_sym] = nil
        refute @patient.valid?
      end
    end

    it 'should require appointment_date to be after initial_call_date' do
      # when initial call date is nil
      @patient.appointment_date = '2016-05-01'
      @patient.initial_call_date = nil
      refute @patient.valid?
      # when initial call date is after appointment date
      @patient.initial_call_date = '2016-06-01'
      refute @patient.valid?
      # when appointment date is nil
      @patient.appointment_date = nil
      assert @patient.valid?
      # when appointment date is after initial call date
      @patient.appointment_date = '2016-07-01'
      assert @patient.valid?
    end

    it 'should save the identifer' do
      assert_equal @patient.identifier, "#{@patient.line[0]}#{@patient.primary_phone[-5]}-#{@patient.primary_phone[-4..-1]}"
    end

    it 'should enforce unique phone numbers' do
      @patient.primary_phone = '111-222-3333'
      @patient.save
      assert @patient.valid?

      @patient2.primary_phone = '111-222-3333'
      refute @patient2.valid?
    end

    it 'should throw two different error messages for duplicates found on same line versus different line' do
      marylandPatient = create :patient, name: 'Susan A in MD',
                                         primary_phone: '777-777-7777',
                                         line: 'MD'
      sameLineDuplicate = create :patient, name: 'Susan B in MD',
                                           line: 'MD'
      diffLineDuplicate = create :patient, name: 'Susan B in VA',
                                           line: 'VA'

      sameLineDuplicate.primary_phone = '777-777-7777'
      diffLineDuplicate.primary_phone = '777-777-7777'

      sameLineDuplicate.save
      diffLineDuplicate.save

      refute sameLineDuplicate.valid?
      refute diffLineDuplicate.valid?

      error1 = sameLineDuplicate.errors.messages[:this_phone_number_is_already_taken]
      error2 = diffLineDuplicate.errors.messages[:this_phone_number_is_already_taken]

      assert_not_equal error1, error2
    end
  end

  describe 'pledge_summary' do
    it 'should return proper pledge summaries for various timespans' do
      @patient.update appointment_date: 2.days.from_now, fund_pledge: 300
      @patient2.update appointment_date: 4.days.from_now, fund_pledge: 500,
                       pledge_sent: true, clinic: create(:clinic)
      # Removed because we don't include resolved_without_fund patients in the summary
      @filtered_pt = create :patient, name: 'Resolved without fund (filtered out)',
                                      appointment_date: 2.days.from_now,
                                      fund_pledge: 100, clinic: create(:clinic),
                                      resolved_without_fund: true
      shaped_patient = patient_to_hash @patient
      shaped_patient2 = patient_to_hash @patient2

      # Testing dates is hard, so we use name as a proxy here
      summary = Patient.pledged_status_summary(:DC)
      assert_equal shaped_patient[:name],
                   summary[:pledged][0][:name]
      assert_equal shaped_patient2[:name],
                   summary[:sent][0][:name]
      assert_nil summary[:pledged].find { |pt| pt[:name] == @filtered_pt.name }
      assert_equal summary[:pledged].count, 1
      assert_equal summary[:sent].count, 1
    end

    it "should include pledges based off of the configured week start" do
      # Here the week starts on Wednesday, and there's a fund pledge from Saturday Jan 20
      # If the week started on Monday (default behavior) then the pledge from Saturday would not be included
      Config.create config_key: :start_of_week,
                    config_value: {options: ['Wednesday']}
      Timecop.freeze("January 20, 1973") { @patient.update! fund_pledge: 300  }
      Timecop.freeze("January 22, 1973") do
        summary = Patient.pledged_status_summary(:DC)
        assert_equal 1, summary[:pledged].count
      end
    end

    it "should exclude pledges based off of the configured week start" do
      # The week starts on Wednesday, and there's a fund pledge from Monday Jan 22
      # If the week started on Monday, the pledge from monday would be included
      Config.create config_key: :start_of_week,
                    config_value: {options: ['Wednesday']}
      Timecop.freeze("January 20, 1973") { @patient.update! fund_pledge: 300  }
      Timecop.freeze("January 24, 1973") do
        summary = Patient.pledged_status_summary(:DC)
        assert_equal 0,summary[:pledged].count
      end
    end

    it "should include pledges sent on the current week, even when the soft pledged was entered in a previous week" do
      # The week starts on Monday Jan 22, there's a soft pledge entered on Jan 20, the week before
      # Update pledge_sent to true on Jan 23, the current week, so it should show up on the week's pledge_status_summary as sent
      Config.create config_key: :start_of_week,
                    config_value: {options: ['Monday']}
      Timecop.freeze("January 20, 1973") { @patient.update! fund_pledge: 250 }                      
      Timecop.freeze("January 23, 1973") { @patient.update! pledge_sent: true, 
                                                            appointment_date: @patient.initial_call_date + 1.day, 
                                                            clinic: create(:clinic) }

      Timecop.freeze("January 25, 1973") do
        summary = Patient.pledged_status_summary(:DC)
        assert_equal 1, summary[:sent].count
      end 

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

    describe 'blow away associated objects on destroy' do
      it 'should nuke associated events in addition to the patient on destroy' do
        create :call_list_entry, patient: @patient
        assert_difference 'Event.count', -1 do
          assert_difference 'CallListEntry.count', -1 do
            @patient.destroy
          end
        end
      end
    end

    describe 'update lines for call list entries on patient change' do
      it 'should update call list entries to push them to the very end' do
        @user = create :user
        create :call_list_entry, patient: @patient, user: @user
        create :call_list_entry, patient: create(:patient, line: 'MD'),
                                 user: @user,
                                 line: 'MD'

        assert_difference "@user.call_list_entries.where(line: 'DC').count", -1 do
          assert_difference "@user.call_list_entries.where(line: 'MD').count", 1 do
            @patient.update line: 'MD'
            @user.reload
          end
        end
        entry = @user.call_list_entries.where(patient: @patient, line: 'MD').first
        assert_equal entry.order_key, 999
      end
    end
  end

  describe 'other methods' do
    before do
      @patient = create :patient, primary_phone: '111-222-3333',
                                  other_phone: '111-222-4444',
                                  name: 'Yolo Goat Bart Simpson'
    end

    it 'primary_phone_display -- should be hyphenated phone' do
      refute_equal @patient.primary_phone, @patient.primary_phone_display
      assert_equal '111-222-3333', @patient.primary_phone_display
    end

    it 'secondary_phone_display - should be hyphenated other phone' do
      refute_equal @patient.other_phone, @patient.other_phone_display
      assert_equal '111-222-4444', @patient.other_phone_display
    end

    it 'initials - creates proper initials' do
      assert_equal 'YGBS', @patient.initials
    end
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @patient.respond_to? :versions
      assert @patient.respond_to? :created_by
      assert @patient.respond_to? :created_by_id
    end
  end

  describe 'methods' do
    describe 'urgent patients class method' do
      before do
        create :patient
        2.times { create :patient, urgent_flag: true }
        create :patient, urgent_flag: true, line: 'MD'
      end

      it 'should return urgent patients by line' do
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

    describe 'destroy_associated_events method' do
      it 'should nuke associated events on patient destroy' do
        assert_difference 'Event.count', -1 do
          @patient.destroy_associated_events
        end
      end
    end

    describe 'okay_to_destroy? method' do
      it 'should return false if pledge is sent' do
        @patient.update appointment_date: 2.days.from_now,
                        fund_pledge: 100,
                        clinic: (create :clinic),
                        pledge_sent: true
        refute @patient.okay_to_destroy?

        @patient[:pledge_sent] = false
        assert @patient.okay_to_destroy?
      end
    end

    describe 'archive_date method' do
      it 'should return a year if unaudited' do
        @patient.fulfillment.update audited: false
        assert_equal @patient.initial_call_date + 1.year, @patient.archive_date
      end
      it 'should return three months if audited' do
        @patient.fulfillment.update audited: true
        assert_equal @patient.initial_call_date + 3.months, @patient.archive_date
      end
    end

    describe 'has_special_circumstances' do
      it 'should return false if there is an empty array' do
        @patient.update special_circumstances: []
        assert_equal @patient.has_special_circumstances, false
      end

      it 'should return false if there are no special circumstances' do
        @patient.update special_circumstances: [nil, nil]
        assert_equal @patient.has_special_circumstances, false
      end

      it 'should return true if there are special circumstances' do
        @patient.update special_circumstances: ['special', 'circumstances']
        assert_equal @patient.has_special_circumstances, true
      end

      it 'should return true if there are special circumstances and nils' do
        @patient.update special_circumstances: [nil, 'circumstances']
        assert_equal @patient.has_special_circumstances, true
      end
    end
  end

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

  def patient_to_hash(patient)
    {
      fund_pledge: patient.fund_pledge,
      pledge_sent: patient.pledge_sent,
      id: patient.id,
      name: patient.name,
      appointment_date: patient.appointment_date,
      pledge_sent_at: patient.pledge_sent_at
    }
  end
end
