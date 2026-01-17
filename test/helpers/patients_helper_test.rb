require 'test_helper'

class PatientsHelperTest < ActionView::TestCase
  describe 'weeks_options' do
    it 'should pluralize properly' do
      assert_equal '1 week', weeks_options.second[0]
      assert_equal '2 weeks', weeks_options.third[0]
      assert_equal 1, weeks_options.select { |x| /week$/.match x[0] }.count
    end

    it 'should have 40 entries' do
      assert_equal 41, weeks_options.count
    end
  end

  describe 'days_options' do
    it 'should pluralize properly' do
      assert_equal '0 days', days_options.second[0]
      assert_equal '1 day', days_options.third[0]
      assert_equal '2 days', days_options.fourth[0]
      assert_equal 1, days_options.select { |x| /day$/.match x[0] }.count
    end

    it 'should have 7 entries' do
      assert_equal 8, days_options.count
    end
  end

  describe 'insurance options' do
    describe 'with a config' do
      before { create_insurance_config }

      it 'should include the option set' do
        expected_insurance_options_array = [nil, 'DC Medicaid', 'Other state Medicaid',
                                    [ 'No insurance', 'No insurance' ],
                                    [ 'Don\'t know', 'Don\'t know' ],
                                    [ 'Prefer not to answer', 'Prefer not to answer'],
                                    [ 'Other (add to notes)', 'Other (add to notes)'] ]
        assert_same_elements insurance_options, expected_insurance_options_array
      end

      it 'should append any non-nil passed options to the end' do
        expected_insurance_options_array = [nil, 'DC Medicaid', 'Other state Medicaid',
                                    [ 'No insurance', 'No insurance' ],
                                    [ 'Don\'t know', 'Don\'t know' ],
                                    [ 'Prefer not to answer', 'Prefer not to answer'],
                                    [ 'Other (add to notes)', 'Other (add to notes)'],
                                    'Friendship' ]
        assert_same_elements expected_insurance_options_array,
                             insurance_options('Friendship')
      end

      it 'should not include defaults if configured' do
        create_hide_defaults_config
        assert_same_elements [nil, 'DC Medicaid', 'Other state Medicaid'], insurance_options
      end
    end

    describe 'without a config' do
      before do
        create_hide_defaults_config should_hide: false
      end
      
      it 'should create a config and return proper options' do
        assert_difference 'Config.count', 1 do
          @options = insurance_options
        end

        expected_insurance_array = [nil,
                                   [ 'No insurance', 'No insurance' ],
                                   [ 'Don\'t know', 'Don\'t know' ],
                                   [ 'Prefer not to answer', 'Prefer not to answer'],
                                   [ 'Other (add to notes)', 'Other (add to notes)'] ]
        assert_same_elements expected_insurance_array, @options
        assert Config.find_by(config_key: 'insurance')
      end
    end
  end

  describe 'clinic options' do
    before do
      @active = create :clinic, name: 'active clinic', active: true
    end

    it 'should return all clinics' do
      @inactive = create :clinic, name: 'closed clinic', active: false
      expected_clinic_array = [
        nil,
        ["#{@active.name} (#{@active.city}, #{@active.state})", @active.id, { data: { naf: false, medicaid: false }}],
        ['--- INACTIVE CLINICS ---', nil, { disabled: true }],
        ["(Not currently working with CATF) - #{@inactive.name}", @inactive.id, { data: { naf: false, medicaid: false }}]
      ]

      assert_same_elements clinic_options, expected_clinic_array
    end

    it 'should skip inactive clinics section if there are not any' do
      expected_clinic_array = [
        nil,
        ["#{@active.name} (#{@active.city}, #{@active.state})", @active.id, { data: { naf: false, medicaid: false }}]
      ]

      assert_same_elements clinic_options, expected_clinic_array
    end
  end

  %w(race_ethnicity employment_status insurance income referred_by
     household_size).each do |array|
    describe "#{array}_options" do
      it "should be a usable array - #{array}_options" do
        options_array = send("#{array}_options".to_sym)
        assert options_array.class == Array
        assert options_array.count > 1
      end
    end
  end

  describe 'state options' do
    it 'should return all states and current value' do
      expected_state_array = [[nil, nil],
	["AL", "AL"],
	["AK", "AK"],
	["AZ", "AZ"],
	["AR", "AR"],
        ["CA", "CA"],
	["CO", "CO"],
	["CT", "CT"],
	["DE", "DE"],
	["DC", "DC"],
	["FL", "FL"],
        ["GA", "GA"],
	["HI", "HI"],
	["ID", "ID"],
	["IL", "IL"],
	["IN", "IN"],
	["IA", "IA"],
        ["KS", "KS"],
	["KY", "KY"],
	["LA", "LA"],
	["ME", "ME"],
	["MD", "MD"],
	["MA", "MA"],
        ["MI", "MI"],
	["MN", "MN"],
	["MS", "MS"],
	["MO", "MO"],
	["MT", "MT"],
	["NE", "NE"],
        ["NV", "NV"],
	["NH", "NH"],
	["NJ", "NJ"],
	["NM", "NM"],
	["NY", "NY"],
	["NC", "NC"],
        ["ND", "ND"],
	["OH", "OH"],
	["OK", "OK"],
	["OR", "OR"],
	["PA", "PA"],
	["RI", "RI"],
        ["SC", "SC"],
	["SD", "SD"],
	["TN", "TN"],
	["TX", "TX"],
	["UT", "UT"],
	["VT", "VT"],
        ["VA", "VA"],
	["WA", "WA"],
	["WV", "WV"],
	["WI", "WI"],
	["WY", "WY"],
	["virginia","virginia"]]

      assert_same_elements state_options("virginia"), expected_state_array
    end
  end

  describe 'voicemail_options' do
    before { create_voicemail_config }
    # stock options
    it 'should return an array based on patient voicemail_options' do
      ['no', 'yes', 'not_specified'].each do |pref|
        refute_empty voicemail_options.select { |opt| opt[1] == pref }
      end
    end

    # with custom options
    it 'should load custom options' do
      assert_includes voicemail_options, 'Use Codename'
      assert_includes voicemail_options, 'Only During Business Hours'
      assert_includes voicemail_options, 'Text Message Only'
    end

    # if option has been removed, should stick around until changed
    it 'should append any non-nil passed options to the end' do
      expected_vm_options_array =
        ['Use Codename', 'Only During Business Hours', 'Text Message Only',
         ['Do not leave a voicemail', 'no'],
         ['Voicemail OK, ID OK', 'yes'],
         ['No instructions; no ID VM', 'not_specified'],
          'ID as coworker'
        ]
      assert_same_elements expected_vm_options_array,
                           voicemail_options('ID as coworker')
    end
  end

  describe 'language_options' do
    before { create_language_config }

    it 'should return default languages' do
      expected_lang_options = [
        ['English', nil],
        'Spanish',
        'French',
        'Korean'
      ]
      assert_same_elements expected_lang_options, language_options()
    end

    it 'should append extra options' do
      expected_lang_options = [
        ['English', nil],
        'Spanish',
        'French',
        'Korean',
        'Esperanto'
      ]
      assert_same_elements expected_lang_options, language_options('Esperanto')
    end
  end

  describe 'referred_by_options' do
    before { create_referred_by_config }

    # base options come from patients_helper
    # Metal band is added by create_referred_by_config
    expected_referrals_base = [
      nil,
      ["Clinic", "Clinic"],
      ["Crime victim advocacy center", "Crime victim advocacy center"],
      ["CATF website or social media", "CATF website or social media"],
      ["Domestic violence crisis/intervention org", "Domestic violence crisis/intervention org"],
      ["Family member", "Family member"],
      ["Friend", "Friend"],
      ["Google/Web search", "Google/Web search"],
      ["Homeless shelter", "Homeless shelter"],
      ["Legal clinic", "Legal clinic"],
      ["NAF", "NAF"],
      ["NNAF", "NNAF"],
      ["Other abortion fund", "Other abortion fund"],
      ["Previous patient", "Previous patient"],
      ["School", "School"],
      ["Sexual assault crisis org", "Sexual assault crisis org"],
      ["Youth outreach", "Youth outreach"],
      ['Prefer not to answer', 'Prefer not to answer'],
      "Metal band"
    ]

    it 'should return default referral options' do
      assert_same_elements expected_referrals_base, referred_by_options()
    end

    it 'should append extra options' do
      expected_referrals = expected_referrals_base + ['Social Worker']

      assert_same_elements expected_referrals, referred_by_options('Social Worker')
    end

    it 'should not include defaults if configured' do
      create_hide_defaults_config

      assert_same_elements ['Metal band'], referred_by_options
    end
  end

  describe 'line_options' do
    before do
      @line1 = create :line, name: 'JJ'
      @line2 = create :line, name: 'Sage'
      @line3 = create :line, name: 'Lomky Jr'
    end

    it 'should return line names and ids' do
      expected = [['JJ', @line1.id], ['Lomky Jr', @line3.id], ['Sage', @line2.id]]
      assert_equal expected, line_options
    end
  end

  describe 'county_options' do
    describe 'with a config' do
      before { create_county_config }

      it 'should include custom counties as well as current' do
        expected_counties = [nil, 'Arlington', 'Fairfax', 'Montgomery',
                              "Prince George's"]
        assert_same_elements expected_counties,
                            county_options("Prince George's")
      end
    end

    describe 'without a config' do
      it 'should create a config and return empty' do
        assert_difference 'Config.count', 1 do
          @options = county_options
        end

        assert_empty @options
        assert Config.find_by(config_key: 'county')
      end
    end
  end

  describe 'procedure_type_options' do
    describe 'with configured options' do
      custom_procedure_types = ['medical', 'evisit', 'in person']
      current_option = 'phone'
      before { create_procedure_type_config(custom_procedure_types) }
      it 'should include custom procedure types as well as current' do
        expected_procedure_types = [nil, [custom_procedure_types], current_option].flatten

        assert_same_elements expected_procedure_types,
                            procedure_type_options(current_option)
      end
    end
    describe 'without configured options' do
      it 'should create a config and return empty' do
        assert_difference 'Config.count', 1 do
          @options = procedure_type_options
        end

        assert_empty @options
        assert Config.find_by(config_key: 'procedure_type')
      end
    end
  end

  describe 'appointment_date_display' do
    it 'should show appointment date + time' do
      @patient = create :patient
      assert_nil appointment_date_display(@patient)

      @patient.appointment_date = Time.new 2022, 10, 31
      assert_equal '10/31/2022', appointment_date_display(@patient)

      @patient.appointment_time = '17:30'
      assert_equal '10/31/2022 @ 5:30 PM', appointment_date_display(@patient)

      @patient.multiday_appointment = true
      assert_equal '10/31/2022 @ 5:30 PM (multi-day)', appointment_date_display(@patient)
    end
  end

  describe 'appointment_date_sort_value' do
    it 'should show appointment date and time as an int' do
      @patient = create :patient
      assert_equal 0, appointment_date_sort_value(@patient)

      @patient.appointment_date = Time.new 2022, 10, 31
      just_date = appointment_date_sort_value(@patient)
      assert 1660000000 < just_date

      @patient.appointment_time = '17:30'
      assert just_date < appointment_date_sort_value(@patient)
    end
  end

  describe 'language_badge' do
    before { @patient = create :patient }

    it 'should return nil if blank or english' do
      @patient.language = 'English'
      assert_nil language_badge(@patient)
      @patient.language = nil
      assert_nil language_badge(@patient)
    end

    it 'should return a span if a language' do
      @patient.language = 'Spanish'
      assert_equal '<span class="badge badge-primary">Spanish speaker</span>', language_badge(@patient)      
    end
  end
end
