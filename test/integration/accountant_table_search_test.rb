require 'test_helper'

class AccountantTableSearchTest < ActionDispatch::IntegrationTest
  before do
    # Capybara.current_driver = :poltergeist
    @user = create :user
    @clinic = create :clinic, name: 'a real clinic'
    @patient = create :patient, name: 'Susan Everyteen Quarry Eileene Zarha', clinic: @clinic
    @patient_2 = create :patient, name: 'Thorny Zarha', clinic: @clinic
    @patient_3_no_fulfillment = create :patient, name: 'Needs Fulfillment Texas'

    @fulfillment = create :fulfillment, fulfilled: true, patient: @patient, created_by: @user
    @fulfillment_2 = create :fulfillment, fulfilled: true, patient: @patient_2, created_by: @user

  end

  # after { Capybara.use_default_driver }

  describe 'only admins can access billing information' do
    before do
      log_in_as @user
    end
    it 'should be unable to access accounting page' do
      visit accountant_path
      refute has_text? 'Accounting'
    end

  end

  describe 'search function' do
    before do
      @user.update role: :admin
      @user.reload
      log_in_as @user

    end

    it 'should navigate to accounting page' do
      visit dashboard_path

      click_link 'Admin tools'
      assert_text 'Accounting'

      wait_for_element 'Accounting'
      click_link 'Accounting'
      wait_for_ajax
      wait_for_element 'Search Cases'
      assert has_content? 'Search Cases'
    end

    it 'initializes with correct number of relevant patients' do
      page.has_css?("tr", :count => 3)
    end

    it 'generates proper initials' do
      assert has_text? 'SEQEZ'
      assert has_text? 'TZ'
      refute has_text? 'NFT'
    end

    it 'will find relevant patients' do
      fill_in 'search', with: 'Thorny'
      click_button 'Search'

      page.has_css?("tr", :count => 2)
    end

    it 'will find relevant patients - 2' do
      fill_in 'search', with: 'Zarha'
      click_button 'Search'

      page.has_css?("tr", :count => 3)
    end
  end

  describe 'patient fulfillment edit' do
    before do
      visit accountant_path
      wait_for_element 'Accounting'
    end

    it 'should open fulfillment modal' do

    end

    it 'should refresh background table on update' do

    end

    it 'should reset paginate number' do
      
    end

  end
end
