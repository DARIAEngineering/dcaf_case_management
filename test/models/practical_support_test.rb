require 'test_helper'

class PracticalSupportTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.practical_supports.create support_type: 'Concert Tickets',
                                       source: 'Metallica Abortion Fund'
    @patient.practical_supports.create support_type: 'Swag',
                                       source: 'YOLO AF',
                                       status: :approved,
                                       support_date: 2.days.from_now
    @patient.practical_supports.create support_type: 'Companion',
                                       source: 'Cat',
                                       amount: 32
    @psupport1 = @patient.practical_supports.first
    @psupport2 = @patient.practical_supports.second
    @psupport3 = @patient.practical_supports.last
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @psupport1.respond_to? :versions
      assert @psupport1.respond_to? :created_by
      assert @psupport1.respond_to? :created_by_id
    end

    describe 'most_recent_note_display_text' do
      before do
        @note = @psupport1.notes.create full_text: (1..100).map(&:to_s).join('')          
      end

      it 'returns 22 characters of the notes text' do
        assert_equal 22, @psupport1.most_recent_note_display_text.length
        assert_match /^1234/, @psupport1.most_recent_note_display_text
      end
    end
  end

  describe 'validations' do
    # note: amount is not required
    [:source, :support_type].each do |field|
      it "should enforce presence of #{field}" do
        @psupport1[field.to_sym] = nil
        refute @psupport1.valid?
      end
    end
  end

  describe 'status enum' do
    it 'should have five status values' do
      assert_equal %w[requested in_progress approved completed cancelled],
                   PracticalSupport.statuses.keys
    end

    it 'should default to requested' do
      support = PracticalSupport.new(source: 'Test', support_type: 'Lodging')
      assert_equal 'requested', support.status
    end

    it 'should allow status transitions' do
      @psupport1.update!(status: :in_progress)
      assert @psupport1.in_progress?

      @psupport1.update!(status: :approved)
      assert @psupport1.approved?

      @psupport1.update!(status: :completed)
      assert @psupport1.completed?
    end
  end

  describe 'overdue scope' do
    it 'should include requested supports older than 7 days by status_updated_at' do
      @psupport1.update_columns(status: 0, status_updated_at: 10.days.ago)
      assert_includes PracticalSupport.overdue, @psupport1
    end

    it 'should exclude completed supports' do
      @psupport1.update_columns(status: 3, status_updated_at: 10.days.ago)
      refute_includes PracticalSupport.overdue, @psupport1
    end

    it 'should exclude recently updated supports' do
      @psupport1.update_columns(status: 0, status_updated_at: 1.day.ago)
      refute_includes PracticalSupport.overdue, @psupport1
    end
  end

  describe 'badge_color' do
    it 'should return correct BS4 badge class per status' do
      @psupport1.status = :requested
      assert_equal 'badge-secondary', @psupport1.badge_color

      @psupport1.status = :in_progress
      assert_equal 'badge-info', @psupport1.badge_color

      @psupport1.status = :approved
      assert_equal 'badge-primary', @psupport1.badge_color

      @psupport1.status = :completed
      assert_equal 'badge-success', @psupport1.badge_color

      @psupport1.status = :cancelled
      assert_equal 'badge-danger', @psupport1.badge_color
    end
  end

  describe 'track_status_change callback' do
    it 'should update status_updated_at when status changes' do
      @psupport1.update!(status: :in_progress)
      assert_not_nil @psupport1.status_updated_at
    end
  end

  describe 'active scope' do
    it 'should exclude completed and cancelled' do
      @psupport1.update!(status: :completed)
      @psupport2.update!(status: :cancelled)

      active = PracticalSupport.active
      refute_includes active, @psupport1
      refute_includes active, @psupport2
      assert_includes active, @psupport3
    end
  end
end
