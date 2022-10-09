require 'test_helper'

class AttackTest < ActionDispatch::IntegrationTest

  include Rack::Test::Methods
  def app
    Rails.application
  end

  before do
    # Prevents ips and emails from conflicting across tests.
    Rails.cache.clear
  end

  describe "throttle excessive requests by IP address" do
    limit = 60

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

          get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
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
          post "/users/sign_in", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/sign_in", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.4"
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
          post "/users/sign_in", { user_email: "example@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/sign_in", { user_email: "example@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  describe "throttle excessive requests to password routes by IP address" do
    limit = 5

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/password", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/password", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.4"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  describe "throttle excessive requests to password routes by email address" do
    limit = 5

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/password", { user_email: "example@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/password", { user_email: "example@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  describe "throttle excessive requests to auth routes by IP address" do
    limit = 5

    describe "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/auth/google_oauth2", {}, "REMOTE_ADDR" => "1.2.3.4"
          assert_not_equal 503, last_response.status, "Should not hit throttle limit"
        end
      end
    end

    describe "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        (limit * 2).times do |i|
          post "/users/auth/google_oauth2", {}, "REMOTE_ADDR" => "1.2.3.4"
          assert_equal(503, last_response.status, "Should hit throttle limit") if i > limit
        end
      end
    end
  end

  Rack::Attack.cache.store.clear
end
