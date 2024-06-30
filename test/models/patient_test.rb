require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  extend Minitest::OptionalRetry

  before do
    @user = create :user
    @line = create :line
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo',
                                line: @line

    @patient2 = create :patient, other_phone: '333-222-3333',
                                other_contact: 'Foobar',
                                line: @line
    @patient.calls.create attributes_for(:call, status: :reached_patient)
    @call = @patient.calls.first
    create_language_config
  end

  describe 'callbacks' do
    before do
      @new_patient = build :patient, name: '  Name With Whitespace  ',
                                     other_contact: ' also name with whitespace ',
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
      assert_equal @patient.identifier, "#{@patient.line.name[0]}#{@patient.primary_phone[-5]}-#{@patient.primary_phone[-4..-1]}"
    end

    it 'should enforce unique phone numbers' do
      @patient.primary_phone = '111-222-3333'
      @patient.save
      assert @patient.valid?

      @patient2.primary_phone = '111-222-3333'
      refute @patient2.valid?
    end

    it 'should throw two different error messages for duplicates found on same line versus different line' do
      line2 = create :line
      line3 = create :line
      marylandPatient = create :patient, name: 'Susan A in MD',
                                         primary_phone: '777-777-7777',
                                         line: line2
      sameLineDuplicate = create :patient, name: 'Susan B in MD',
                                           line: line2
      diffLineDuplicate = create :patient, name: 'Susan B in VA',
                                           line: line3

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

    it 'should validate zipcode format' do
      # wrong len
      @patient.zipcode = '000'
      refute @patient.valid?

      # disallowed characters
      @patient.zipcode = 'Z6B 1A7'
      refute @patient.valid?

      ## zip +4
      @patient.zipcode = '00000-1111'
      assert @patient.valid?

      @patient.zipcode = '123456789'
      assert @patient.valid?
      assert_equal '12345-6789', @patient.zipcode

      @patient.zipcode = '00000-111'
      refute @patient.valid?

      @patient.zipcode = '00000-11111'
      refute @patient.valid?

      @patient.zipcode = '12345'
      @patient.save
      assert @patient.valid?
    end
  end

  describe 'pledge_summary' do
    it 'should return proper pledge summaries for various timespans' do
      noon = Time.zone.today.beginning_of_day + 12.hours
      # to ensure this spec isn't flaky if someone runs it between 12am - 4am ET
      Timecop.freeze(noon) do
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
        summary = Patient.pledged_status_summary(@line)
        assert_equal shaped_patient[:name],
                    summary[:pledged][0][:name]
        assert_equal shaped_patient2[:name],
                    summary[:sent][0][:name]
        assert_nil summary[:pledged].find { |pt| pt[:name] == @filtered_pt.name }
        assert_equal summary[:pledged].count, 1
        assert_equal summary[:sent].count, 1
      end
    end

    it "should include pledges based off of the configured week start" do
      # Here the week starts on Wednesday, and there's a fund pledge from Saturday Jan 20
      # If the week started on Monday (default behavior) then the pledge from Saturday would not be included
      Config.create config_key: :start_of_week,
                    config_value: {options: ['Wednesday']}
      Timecop.freeze("January 20, 1973") { @patient.update! fund_pledge: 300  }
      Timecop.freeze("January 22, 1973") do
        summary = Patient.pledged_status_summary(@line)
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
        summary = Patient.pledged_status_summary(@line)
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
        summary = Patient.pledged_status_summary(@line)
        assert_equal 1, summary[:sent].count
      end 
    end

    it "should be time zone aware and only include pledges sent in the current week for the configured time zone" do
      Config.create config_key: :time_zone,
                    config_value: {options: ['Pacific']}
      
      tuesday_in_pacific = Time.zone.local(2023, 2, 7, 11, 30, 45)
      early_monday_morning_in_pacific = Time.zone.local(2023, 2, 6, 8, 30, 45)
      late_sunday_evening_in_pacific = Time.zone.local(2023, 2, 6, 1, 30, 45)

      @patient.update(appointment_date: tuesday_in_pacific, initial_call_date: tuesday_in_pacific - 1.day, fund_pledge: 300)
      @patient2.update(appointment_date: early_monday_morning_in_pacific, initial_call_date: early_monday_morning_in_pacific - 1.day, fund_pledge: 500, pledge_sent: true, clinic: create(:clinic))
      # Removed because we don't include patient's with appt's outside of current week (time zone aware)
      @filtered_pt = create(:patient, name: 'Outside of the time zone week', appointment_date: late_sunday_evening_in_pacific, initial_call_date: late_sunday_evening_in_pacific - 1.day, fund_pledge: 100, clinic: create(:clinic))
      shaped_patient = patient_to_hash @patient
      shaped_patient2 = patient_to_hash @patient2

      Timecop.freeze(tuesday_in_pacific) do
        # Testing dates is hard, so we use name as a proxy here
        summary = Patient.pledged_status_summary(@line)
        assert_equal shaped_patient[:name],
                    summary[:pledged][0][:name]
        assert_equal shaped_patient2[:name],
                    summary[:sent][0][:name]
        assert_nil summary[:pledged].find { |pt| pt[:name] == @filtered_pt.name }
        assert_nil summary[:sent].find { |pt| pt[:name] == @filtered_pt.name }
        assert_equal summary[:pledged].count, 1
        assert_equal summary[:sent].count, 1
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

    describe 'confirm still shared' do
      before do
        create :clinic
        @patient = create :patient, shared_flag: true,
                                    clinic: Clinic.first,
                                    appointment_date: 2.days.from_now,
                                    fund_pledge: 300
      end

      it "should unflag after update if resolved_without_fund" do
        @patient.update resolved_without_fund: true
        refute @patient.shared_flag
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
        @line2 = create :line
        @line3 = create :line
        create :call_list_entry, patient: @patient, user: @user, line: @line2
        create :call_list_entry, patient: create(:patient, line: @line3),
                                 user: @user,
                                 line: @line3

        assert_difference "@user.call_list_entries.where(line: @line2).count", -1 do
          assert_difference "@user.call_list_entries.where(line: @line3).count", 1 do
            @patient.update line: @line3
            @user.reload
          end
        end
        entry = @user.call_list_entries.where(patient: @patient, line: @line3).first
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

    it 'should show appointment date + time' do
      assert_nil @patient.appointment_date_display

      @patient.appointment_date = Time.new 2022, 10, 31
      assert_equal @patient.appointment_date_display, '10/31/2022'

      @patient.appointment_time = '17:30'
      assert_equal @patient.appointment_date_display, '10/31/2022 @ 5:30 PM'
    end
  end

  describe 'methods' do
    describe 'shareable concern methods' do
      describe 'shared_patients class method' do
        before do
          @line = create :line
          @line2 = create :line
          with_versioning do
            create :patient
            2.times { create :patient, shared_flag: true, line: @line }
            create :patient, shared_flag: true, line: @line2
          end
        end

        it 'should return shared patients by line' do
          assert_equal 2, Patient.shared_patients(@line).count
          assert_equal 1, Patient.shared_patients(@line2).count
        end
      end

      describe 'trim_shared_patients method' do
        it 'should trim shared patients after they have been inactive or resolved' do
          @patient.update shared_flag: true
          @patient.update resolved_without_fund: true
          Patient.trim_shared_patients
          assert_not @patient.shared_flag
        end
      end

      describe 'still_shared? method' do
        it 'should return false if resolved without fund' do
          @patient.update shared_flag: true
          @patient.update resolved_without_fund: true
          assert_not @patient.still_shared?
        end

        describe 'without a custom shared_reset config' do
          it 'should return true if marked shared in last 6 days' do
            with_versioning do
              @patient.update shared_flag: true
              @patient.reload
            end
            assert @patient.still_shared?
          end


          it 'should return false if not updated for more than 6 days' do
            Timecop.freeze(Time.zone.now - 7.days) do
              with_versioning do
                @patient.update shared_flag: true
                @patient.reload
              end
            end

            assert_not @patient.still_shared?
          end
        end

        describe 'with a custom shared reset config' do
          before do
            c = Config.find_or_create_by(config_key: 'shared_reset')
            c.config_value = { options: ["14"] }
            c.save
          end

          after do
            Config.find_or_create_by(config_key: 'shared_reset').delete
          end

          it 'should return true if shared in the last configured days' do
            Timecop.freeze(Time.zone.now - 7.days) do
              with_versioning do
                @patient.update shared_flag: true
                @patient.reload
              end
            end

            assert @patient.still_shared?
          end

          it 'should return false if not updated in the last configured days' do
            Timecop.freeze(Time.zone.now - 15.days) do
              with_versioning do
                @patient.update shared_flag: true
                @patient.reload
              end
            end

            assert_not @patient.still_shared?
          end
        end
      end
    end

    describe 'saving identifier method' do
      it 'should return a identifier' do
        @patient.update primary_phone: '111-333-5555'
        assert_equal 'L3-5555', @patient.save_identifier
      end
    end


    describe 'most_recent_note_display_text method' do
      before do
        @note = create :note, patient: @patient,
          full_text: (1..100).map(&:to_s).join('')
      end

      it 'returns 22 characters of the notes text' do
        assert_equal 22, @patient.most_recent_note_display_text.length
        assert_match /^1234/, @patient.most_recent_note_display_text
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
        assert_equal @patient.initial_call_date + 365.days, @patient.archive_date
      end
      it 'should return three months if audited' do
        @patient.fulfillment.update audited: true
        assert_equal @patient.initial_call_date + 90.days, @patient.archive_date
      end

      it 'should return custom audit config' do
        c = Config.find_or_create_by(config_key: 'days_to_keep_all_patients')
        c.config_value = { options: ["100"] }
        c.save

        c = Config.find_or_create_by(config_key: 'days_to_keep_fulfilled_patients')
        c.config_value = { options: ["300"] }
        c.save

        @patient.fulfillment.update audited: false
        assert_equal @patient.initial_call_date + 100.days, @patient.archive_date

        @patient.fulfillment.update audited: true
        assert_equal @patient.initial_call_date + 300.days, @patient.archive_date
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

    describe 'unconfirmed_practical_support' do
      before do
        # unconfirmed support, should show up
        @patient.practical_supports.create support_type: 'Companion',
                                          source: 'Cat',
                                          amount: 32,
                                          confirmed: false

        # confirmed support, should not show up
        @patient2.practical_supports.create support_type: 'Lodging',
                                            source: 'Fund',
                                            amount: 100,
                                            confirmed: true

        # no practical support, also should not show up
        @patient3 = create :patient, other_phone: '333-222-1111',
                            other_contact: 'Cats',
                            line: @line
      end

      context 'when a patient has unconfirmed supports' do
        it 'includes only the patient with unconfirmed support' do
          assert_includes Patient.unconfirmed_practical_support(@line), @patient
          assert_not_includes Patient.unconfirmed_practical_support(@line), @patient2
          assert_not_includes Patient.unconfirmed_practical_support(@line), @patient3
        end
      end

      context 'when supports are confirmed' do
        it 'no longer includes the patient' do
          @patient.practical_supports.each {|x| x.update confirmed: true}
          assert_empty Patient.unconfirmed_practical_support(@line)
        end
      end

      context 'when a patient has multiple supports' do
        before do
          @patient.practical_supports.first.update confirmed: false

          @patient.practical_supports.create support_type: 'Lodging',
                                             source: 'Fund',
                                             amount: 200,
                                             confirmed: false
        end

        it 'should not return duplicates when multiple unconfirmed supports exist' do
          assert_no_difference 'Patient.unconfirmed_practical_support(@line).length' do
            @patient.practical_supports.create support_type: 'Travel to the region',
                                              source: 'Catbus',
                                              amount: 50,
                                              confirmed: false
          end  
        end

        it 'returns the patient when some supports are confirmed' do
          assert_no_difference 'Patient.unconfirmed_practical_support(@line).length' do
            @patient.practical_supports.first.update confirmed: true
          end
        end

        it 'no longer returns the patient when all supports are confirmed' do
          assert_difference 'Patient.unconfirmed_practical_support(@line).length', -1 do
            @patient.practical_supports.each { |support| support.update confirmed: true }
          end
        end
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

    it "should not validate pledge_sent if the fund pledge field is blank" do
      @patient.fund_pledge = nil
      @patient.pledge_sent = true
      refute @patient.valid?
      assert_equal ["CATF pledge field cannot be blank"], @patient.errors.messages[:pledge_sent]
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
      assert_equal ["CATF pledge field cannot be blank", 'Clinic name cannot be blank', 'Appointment date cannot be blank'],
      @patient.errors.messages[:pledge_sent]
    end

    it 'should have convenience methods to render in view, just in case' do
      refute @patient.pledge_info_present?
      @patient.fund_pledge = nil
      assert @patient.pledge_info_present?
      assert_equal ["CATF pledge field cannot be blank"], @patient.pledge_info_errors
    end

    it 'should update sent by and sent at when sending the pledge' do
      @user = create :user
      @patient.update fund_pledge: 500,
                      clinic: @clinic,
                      appointment_date: 14.days.from_now,
                      last_edited_by: @user,
                      pledge_sent: true
      @patient.reload
      assert_in_delta Time.zone.now.to_f, @patient.pledge_sent_at.to_f, 15 #used assert_in_delta to account for slight differences in timing. Allows 15 seconds of lag?
      assert_equal @user, @patient.pledge_sent_by
    end

    it 'should set pledge sent and sent at to nil if a pledge is cancelled' do
      @patient.update pledge_sent: false
      @patient.reload
      assert_nil @patient.pledge_sent_by
      assert_nil @patient.pledge_sent_at
    end
  end

  describe 'all_versions' do
    before do
      # For some reason bullet doesn't play nicely with these unit tests,
      # but does with the system tests. Given the choice I prefer the system
      # tests, so we assume this is a false negative and turn off bullet for these.
      Bullet.enable = false
      with_versioning do
        @patient.update name: 'Cat Patient'
        @patient.external_pledges.create amount: 100, source: 'Catfund'
        @patient.practical_supports.create amount: 100, support_type: 'Cat petting', source: 'Catfund'
        @patient.fulfillment.update check_number: 'Cat1'
      end
    end

    after do
      Bullet.enable = true
    end

    it 'should not show fulfillment if not include_fulfillment' do
      version_types = @patient.all_versions(false).map(&:item_type).uniq
      assert_includes version_types, 'ExternalPledge'
      assert_includes version_types, 'PracticalSupport'
      assert_includes version_types, 'Patient'
      assert_not_includes version_types, 'Fulfillment'
    end

    it 'should show fulfillment if include_fulfillment' do
      version_types = @patient.all_versions(true).map(&:item_type).uniq
      assert_includes version_types, 'ExternalPledge'
      assert_includes version_types, 'PracticalSupport'
      assert_includes version_types, 'Patient'
      assert_includes version_types, 'Fulfillment'
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
