require 'test_helper'

class ExternalPledgeTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.external_pledges.create amount: 100,
                                     source: 'BWAH'
    @pledge = @patient.external_pledges.first
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @pledge.respond_to? :versions
      assert @pledge.respond_to? :created_by
      assert @pledge.respond_to? :created_by_id
    end
  end

  describe 'validations' do
    [:source, :amount].each do |field|
      it "should enforce presence of #{field}" do
        @pledge[field.to_sym] = nil
        refute @pledge.valid?
      end
    end

    it 'should scope source uniqueness to patient' do
      pledge = @patient.external_pledges
                       .create attributes_for(:external_pledge,
                                              amount: 200,
                                              source: 'BWAH')
      refute pledge.valid?

      pledge.source = 'Other Fund'
      assert pledge.valid?
    end
  end

  describe 'scopes' do
    before do
      @patient.external_pledges.create! amount: 100,
                                        source: 'Bar',
                                        active: false
    end

    it 'should leave inactive pledges out unless specified queries' do
      @patient.reload
      assert_equal 1, @patient.external_pledges.count
      assert_equal 1, @patient.external_pledges.active.count
      assert_equal 2, @patient.external_pledges.unscoped.count
    end
  end

  describe 'russian-doll caching (touch: true)' do
    it 'should touch parent patient when pledge is created' do
      original_updated_at = @patient.updated_at

      travel 1.second do
        @patient.external_pledges.create amount: 50, source: 'New Source'
      end

      @patient.reload
      assert @patient.updated_at > original_updated_at,
             'Patient updated_at should be bumped when a pledge is created'
    end

    it 'should touch parent patient when pledge is updated' do
      @patient.reload
      original_updated_at = @patient.updated_at

      travel 1.second do
        @pledge.update!(amount: 999)
      end

      @patient.reload
      assert @patient.updated_at > original_updated_at,
             'Patient updated_at should be bumped when a pledge is updated'
    end
  end
end
