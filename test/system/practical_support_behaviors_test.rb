require 'application_system_test_case'

class PracticalSupportBehaviorsTest < ApplicationSystemTestCase
  extend Minitest::OptionalRetry

  before do
    @line = create :line
    @user = create :user
    @patient = create :patient, line: @line
    create_display_practical_support_attachment_url_config
    create_display_practical_support_waiver_config
  end

  describe 'marking patient level data' do
    it 'should hide if no config' do
      Config.find_by(config_key: 'display_practical_support_waiver').update config_value: { options: ['no'] }
      go_to_practical_support_tab
      assert_not has_text? 'practical support waiver'
    end

    it 'should be there and save if config' do
      go_to_practical_support_tab
      check 'Has signed a practical support waiver'
      reload_page_and_click_link 'Practical Support'
      assert has_checked_field? 'Has signed a practical support waiver'
    end
  end

  describe 'creating a new practical support entry' do
    before { go_to_practical_support_tab }

    it 'should start empty' do
      within :css, '#practical-support-entries' do
        assert has_no_text? 'Update'
      end
    end

    it 'should log a new practical support' do
      within :css, '#practical-support-new-form' do
        select 'Companion', from: 'practical_support_support_type'
        select 'Other (see notes)', from: 'practical_support_source'
        fill_in 'Amount', with: 500.10
        fill_in 'Attachment URL', with: 'www.google.com'
        fill_in 'Support date', with: 5.days.from_now.strftime('%m/%d/%Y')
        fill_in 'Purchase date', with: 6.days.from_now.strftime('%m/%d/%Y')
        check 'Confirmed'
        check 'Fulfilled'
        click_button 'Create new practical support'
      end

      within :css, '#practical-support-entries' do
        assert_equal "(Confirmed) (Fulfilled) Companion from Other (see notes) on #{5.days.from_now.display_date} for $500.10 (Purchased on #{6.days.from_now.display_date})",
                     find('.practical-support-display-text').text
        click_link 'Update'
      end

      within :css, '.modal' do
        assert_equal 'Companion', find('#practical_support_support_type').value
        assert_equal 'Other (see notes)', find('#practical_support_source').value
        assert_equal '500.10', find('#practical_support_amount').value
        assert_equal 'www.google.com', find('#practical_support_attachment_url').value
        assert_equal 5.days.from_now.strftime('%Y-%m-%d'), find('#practical_support_support_date').value
        assert_equal 6.days.from_now.strftime('%Y-%m-%d'), find('#practical_support_purchase_date').value
        assert has_checked_field? 'Confirmed'
        assert has_checked_field? 'Fulfilled'
      end
    end

    it 'should fail with a message on failed create' do
      # Leaving support_type blank should do it!
      within :css, '#practical-support-new-form' do
        click_button 'Create new practical support'
      end

      assert has_text? "Practical support failed to save: Source can't be blank and Support type can't be blank"

      within :css, '#practical-support-entries' do
        assert has_no_selector? '#practical_support_support_type'
      end
    end
  end

  describe 'updating practical support entries' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other (see notes)',
                                         amount: 100.45
      @support = @patient.practical_supports.first
      go_to_practical_support_tab
    end

    it 'should save if valid and changed' do
      within :css, "#practical-support-item-#{@support.id}" do
        click_link 'Update'
      end
      within :css, '.modal' do
        select 'Cat Fund', from: 'practical_support_source'
        fill_in 'Attachment URL', with: 'www.google.com'
        check 'Confirmed'
        check 'Fulfilled'
      end
      sleep 1
      assert has_text? 'Patient info successfully saved'
      click_button 'Close'

      reload_page_and_click_link 'Practical Support'
      within :css, '#practical-support-entries' do
        assert_equal '(Confirmed) (Fulfilled) Other (see notes) from Cat Fund for $100.45',
                     find('.practical-support-display-text').text
      end
    end

    it 'should fail if changed to invalid' do
      within :css, "#practical-support-item-#{@support.id}" do
        click_link 'Update'
      end
      within :css, '.modal' do
        select '', from: 'practical_support_source'
        send_keys :tab
      end
      sleep 1
      assert has_text? "Practical support failed to save: Source can't be blank"
      click_button 'Close'

      reload_page_and_click_link 'Practical Support'
      within :css, '#practical-support-entries' do
        assert_equal 'lodging from Other (see notes) for $100.45', find('.practical-support-display-text').text
      end
    end

    it 'should let you take notes' do
      within :css, "#practical-support-item-#{@support.id}" do
        click_link 'Update'
      end

      within :css, '.modal' do
        click_button 'Notes'
        fill_in 'note[full_text]', with: 'hello'
        click_button 'Create Note'
        sleep 1
      end
      within :css, '.notes-form' do
        assert has_text? 'hello'
      end
      click_button 'Close'

      reload_page_and_click_link 'Practical Support'
      within :css, '.practical-support-note-preview' do
        assert has_text? 'hello'
      end
    end
  end

  describe 'destroying a practical support entry' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other (see notes)'
      @support = @patient.practical_supports.first
      go_to_practical_support_tab
    end

    it 'destroy practical supports if you click the big red button' do
      within :css, '#practical-support-entries' do
        click_link 'Update'
      end
      within :css, '.modal' do
        accept_confirm { click_button 'Delete' }
      end
      sleep 1
      click_button 'Close'

      reload_page_and_click_link 'Practical Support'
      within :css, '#practical-support-entries' do
        assert has_no_selector? "#practical-support-item-#{@support.id}"
      end
    end
  end

  describe 'hiding practical support' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other (see notes)'
    end

    it 'can hide the practical support tab' do
      @config = Config.find_or_create_by(config_key: 'hide_practical_support', config_value: { options: ['Yes'] })
      go_to_edit_page
      assert has_no_text? /Practical Support/i
    end

    it 'shows the practical support tab by default' do
      go_to_edit_page
      assert has_text? /Practical Support/i
    end
  end

  describe 'unconfirmed dashboard behavior' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other (see notes)',
                                         confirmed: false
    end

    it 'shows unconfirmed patients' do
      log_in_as @user
      visit dashboard_path
      within :css, '#unconfirmed_support' do
        assert has_text? @patient.name
      end
    end

    it 'does not show confirmed patients' do
      # set confirmed
      go_to_practical_support_tab

      within :css, '#practical-support-entries' do
        click_link 'Update'
      end
      within :css, '.modal' do
        check 'Confirmed'
      end
      wait_for_ajax

      visit dashboard_path
      within :css, '#unconfirmed_support' do
        assert_not has_text? @patient.name
      end
    end
  end
end

def go_to_practical_support_tab
  go_to_edit_page
  click_link 'Practical Support'
end

def go_to_edit_page
  log_in_as @user
  visit edit_patient_path @patient
  has_text? 'First and last name' # wait for element
end

def reload_page_and_click_link(link_text)
  click_away_from_field
  visit authenticated_root_path
  visit edit_patient_path @patient
  click_link link_text
end
