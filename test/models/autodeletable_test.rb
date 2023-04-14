require 'test_helper'

class AutodeletableTest < ActiveSupport::TestCase
    before do
        @line = create :line, name: 'DC'
        @pt_a = create :patient,
                        name: 'Amanda',
                        primary_phone: '222-222-2222',
                        line: @line,
                        initial_call_date: 10.days.ago
        @pt_b = create :patient,
                        name: 'Bethany',
                        primary_phone: '333-333-3333',
                        line: @line,
                        initial_call_date: 0.days.ago
        @pt_c = create :patient,
                        name: 'Charley',
                        primary_phone: '444-444-4444',
                        line: @line,
                        initial_call_date: 400.days.ago
        @pt_d = create :archived_patient,
                        line: @line,
                        initial_call_date: 400.days.ago

    end

    # by default, no deletion: config is nil
    describe 'without autodeletion' do
        it 'should return nil deletion date' do
            assert_nil Config.days_until_delete

            assert_nil @pt_a.delete_date

            assert_no_difference 'Patient.count' do
                Patient.autodelete!
            end

            assert_no_difference 'ArchivedPatient.count' do
                ArchivedPatient.autodelete!
            end
        end
    end

    describe 'with autodeletion' do
        before do
            c = Config.find_or_create_by(config_key: 'days_until_delete')
            c.config_value = { options: ["100"] }
            c.save!
        end

        it 'should only delete patients outside the window' do
            assert_difference 'Patient.count', -1 do
                Patient.autodelete!
            end

            # specifically, that should be pt_c
            refute_includes Patient.all, @pt_c

            assert_difference 'ArchivedPatient.count', -1 do
                ArchivedPatient.autodelete!
            end
        end
    end

    describe 'edge cases' do
        describe 'config 0 days' do
            before do
                c = Config.find_or_create_by(config_key: 'days_until_delete')
                c.config_value = { options: ["0"] }
                c.save!
            end

            it 'if config is 0, delete all patients now' do
                Timecop.freeze(1.hour.ago) do
                    Patient.autodelete!
                    # delete doesn't occur because now hasn't happened yet ;)
                    assert_equal 1, Patient.count
                end

                Timecop.freeze(1.day.after) do
                    # 2 hours later, now has happened
                    Patient.autodelete!
                    assert_equal 0, Patient.count
                end
            end
        end
        
        describe 'nonzero config on the edge' do
            before do
                c = Config.find_or_create_by(config_key: 'days_until_delete')
                c.config_value = { options: ["10"] }
                c.save!
            end

            it 'deletes pt_a on the right day' do
                Timecop.freeze(1.day.ago) do
                    Patient.autodelete!
                    assert_includes Patient.all, @pt_a
                end

                # present day - doesn't delete because <, not <=
                Patient.autodelete!
                assert_includes Patient.all, @pt_a

                Timecop.freeze(1.day.after) do
                    Patient.autodelete!
                    refute_includes Patient.all, @pt_a
                end       
            end
        end
    end
end