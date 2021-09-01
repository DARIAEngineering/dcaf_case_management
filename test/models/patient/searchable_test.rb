require 'test_helper'
require_relative '../patient_test'

class PatientTest::PatientSearchable < PatientTest
  describe 'search method' do
    before do
      dc = create :line, name: 'DC'
      md = create :line, name: 'MD'
      @pt_1 = create :patient, name: 'Susan Sher',
                               primary_phone: '124-456-6789',
                               line: dc
      @pt_2 = create :patient, name: 'Susan E',
                               primary_phone: '124-567-7890',
                               other_contact: 'Friend Ship',
                               line: dc
      @pt_3 = create :patient, name: 'Susan A',
                               primary_phone: '555-555-5555',
                               other_phone: '999-999-9999',
                               line: dc
      @pt_4 = create :patient, name: 'Susan A in MD',
                               primary_phone: '777-777-7777',
                               other_phone: '999-111-9888',
                               line: md
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

    describe 'limit' do
      before do
        16.times do |num|
          create :patient, primary_phone: "124-567-78#{num+10}"
        end
      end

      it 'should default to 15' do
        assert_equal 15, Patient.search('124').count
      end

      it 'should allow a kwarg to set limit' do
        assert_equal 7, Patient.search('124', search_limit: 7).count
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
      assert_equal 1, Patient.search('Susan A', lines: 'MD').count
    end

    it 'should not choke if it does not find anything' do
      assert_equal 0, Patient.search('no entries with this').count
    end
  end
end