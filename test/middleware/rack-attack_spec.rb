require 'test_helper'

class AttackTest < ActionDispatch::IntegrationTest

  include Rack::Test::Methods
  def app
    Rails.application
  end

  describe "throttle excessive requests by IP address" do
    limit = 300

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do
          get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit + 2).times do |i|

          get "/", {}, "REMOTE_ADDR" => "1.2.3.5"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  describe "throttle excessive POST requests to user sign in by IP address" do
    limit = 5

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", { email: "example3#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.7"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/sign_in", { email: "example4#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.9"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  describe "throttle excessive POST requests to user sign in by email address" do
    limit = 5

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", { user_email: "example7@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.6.9"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/sign_in", { user_email: "example8@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.7.9"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  Rack::Attack.cache.store.clear
end
