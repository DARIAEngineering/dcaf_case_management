require 'test_helper'

class OverdueSupportAlertJobTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @admin = create :user, role: :admin
    @patient = create :patient
    @patient.practical_supports.create support_type: 'Lodging',
                                       source: 'Fund'
    @support = @patient.practical_supports.first
    @support.update_columns(status: 0, status_updated_at: 10.days.ago)
  end

  describe 'when Notification model is not defined' do
    it 'should skip gracefully and log a message' do
      hide_const_if_defined('Notification')

      assert_nothing_raised do
        OverdueSupportAlertJob.perform_now
      end
    end
  end

  describe 'when Notification model is available' do
    before do
      build_notification_stub
    end

    after do
      Object.send(:remove_const, :Notification) if defined?(Notification)
    end

    it 'should create notifications for overdue supports' do
      OverdueSupportAlertJob.perform_now
      assert Notification.notifications.any? { |n| n[:notification_type] == 'overdue_support' },
             'Expected an overdue_support notification to be created'
    end

    it 'should address notifications to admin users' do
      OverdueSupportAlertJob.perform_now
      notified_user_ids = Notification.notifications.map { |n| n[:user].id }
      assert_includes notified_user_ids, @admin.id
    end

    it 'should include patient link in notification' do
      OverdueSupportAlertJob.perform_now
      links = Notification.notifications.map { |n| n[:link] }
      assert links.any? { |l| l.include?(@patient.id.to_s) },
             'Expected notification link to reference the patient'
    end

    it 'should not duplicate notifications for the same support' do
      OverdueSupportAlertJob.perform_now
      first_count = Notification.notifications.size

      OverdueSupportAlertJob.perform_now
      assert_equal first_count, Notification.notifications.size,
                   'Expected no duplicate notifications on second run'
    end

    it 'should not notify about completed supports' do
      @support.update_columns(status: 3, status_updated_at: 10.days.ago)
      OverdueSupportAlertJob.perform_now
      assert_empty Notification.notifications,
                   'Expected no notifications for completed supports'
    end

    it 'should not notify about recently updated supports' do
      @support.update_columns(status: 0, status_updated_at: 1.day.ago)
      OverdueSupportAlertJob.perform_now
      assert_empty Notification.notifications,
                   'Expected no notifications for recent supports'
    end
  end

  private

  def hide_const_if_defined(const_name)
    Object.send(:remove_const, const_name.to_sym) if Object.const_defined?(const_name)
  end

  # Minimal in-memory stub for the Notification model used by the job.
  def build_notification_stub
    Object.send(:remove_const, :Notification) if defined?(Notification)
    stub_class = Class.new do
      class << self
        def notifications
          @notifications ||= []
        end

        def reset!
          @notifications = []
        end

        def notify!(user:, notification_type:, title:, body:, link:)
          notifications << {
            user: user,
            notification_type: notification_type,
            title: title,
            body: body,
            link: link
          }
        end

        def where(attrs = {})
          OverdueSupportAlertJobTest::WhereProxy.new(notifications, attrs)
        end
      end
    end

    Object.const_set(:Notification, stub_class)
    Notification.reset!
  end

  # Simple proxy that responds to .exists? for the dedup check
  class WhereProxy
    def initialize(notifications, attrs)
      @notifications = notifications
      @attrs = attrs
    end

    def exists?
      @notifications.any? do |n|
        @attrs.all? { |k, v| v.nil? ? n[k].nil? : n[k] == v }
      end
    end
  end
end
