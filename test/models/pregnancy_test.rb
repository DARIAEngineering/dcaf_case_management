require 'test_helper'

class PregnancyTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pt_1 = create :patient, name: 'Susan Everywoman', primary_phone: '123-456-6789'
    @pt_2 = create :patient, name: 'Susan Everyteen', primary_phone: '123-456-6789'
    @pt_3 = create :patient, name: 'Susan Everygirl', secondary_phone: '999-999-9999'
    [@pt_1, @pt_2, @pt_3].each do |pt|
      create :pregnancy, patient: pt, created_by: @user
    end
    @pregnancy = @pt_1.pregnancies.first
  end

  describe 'search method' do
    it 'should respond to search' do
      assert Patient.respond_to? :search
    end

    it 'should find a patient' do
      assert_equal Patient.search('Susan Everywoman').count, 1
    end

    it 'should find multiple patients if there are multiple' do
      assert_equal Patient.search('123-456-6789').count, 2
    end

    it 'should be able to find based on secondary phones too' do
      assert_equal Patient.search('999-999-9999').count, 1
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @pregnancy.respond_to? field
        assert @pregnancy[field]
      end
    end

    it 'should respond to history methods' do
      assert @pregnancy.respond_to? :history_tracks
      assert @pregnancy.history_tracks.count > 0 
    end

    it 'should have accessible userstamp methods' do 
      assert @pregnancy.respond_to? :created_by
      assert @pregnancy.created_by
    end
  end  
end
