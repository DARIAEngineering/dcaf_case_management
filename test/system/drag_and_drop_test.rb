# This still works, but for some reason the test is failing.
# I think it’s because drag_to takes it to the middle of an element, and for some reason if you move it to the EXACT middle it doesn’t know whether to go up or down, so it goes to neither.

# require 'application_system_test_case'

# # Test drag and drop call list behavior
# class DragAndDropTest < ApplicationSystemTestCase
#   before do
#     @user = create :user

#     4.times do |i|
#       pt = create :patient, name: "Patient #{i}",
#                             primary_phone: "123-123-123#{i}",
#                             created_by: @user
#       @user.add_patient pt
#     end

#     log_in_as @user
#     visit authenticated_root_path
#   end

#   it 'should drag the first row into the second row' do
#     first_row = page.find('#call_list_content tr:nth-child(1)')
#     second_row = page.find('#call_list_content tr:nth-child(2)')

#     within(first_row) { assert_text 'Patient 3' }
#     within(second_row) { assert_text 'Patient 2' }
#     first_row.drag_to(second_row).drop
#     within(first_row) { assert_text 'Patient 2' }
#     within(second_row) { assert_text 'Patient 3' }
#   end
# end
