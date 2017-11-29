require 'application_system_test_case'

class DragAndDropTest < ApplicationSystemTestCase
  before do
    @user = create :user
    log_in_as @user

    4.times do |i|
      pt = create :patient, name: "Patient #{i}",
                            primary_phone: "123-123-123#{i}",
                            created_by: @user
      @user.add_patient pt
    end
  end

  it 'should drag the first row into the second row' do
    visit '/'
    first_row = page.find('#call_list_content tr:nth-child(1)')
    second_row = page.find('#call_list_content tr:nth-child(2)')

    within(first_row) { assert_text 'Patient 3' }
    within(second_row) { assert_text 'Patient 2' }
    first_row.drag_to(second_row)
    within(first_row) { assert_text 'Patient 2' }
    within(second_row) { assert_text 'Patient 3' }
  end
end
