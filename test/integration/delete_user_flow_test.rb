require 'test_helper'

class DeleteUserFlowTest < ActionDispatch::IntegrationTest
    test "returns ok when twilio will respond" do
        post '/users/delete', params: { "From": "+11235551283", "Body": "Start"}
        assert_response :success
        assert_empty @response.body
    end

    test "returns ok when user doesn't exist" do
        post '/users/delete', params: { "From": "+11111111111", "Body": "Doh!"}
        assert_response :success
        assert_empty @response.body
    end

    test "deletes all records for a user" do
        post '/users/delete', params: { "From": "+11235551283", "Body": "Delete all"}
        assert_response :success

        expected_response = Twilio::TwiML::MessagingResponse.new { |resp| resp.message(body: "Deleted all data for +11235551283. Goodbye!") }
        assert_equal expected_response.to_s, @response.body
        assert_empty User.where(phone: "+11235551283")
    end

    test "deletes all records for a user/zip" do
        post '/users/delete', params: { "From": "+11235551283", "Body": "Delete 20252"}
        assert_response :success

        expected_response = Twilio::TwiML::MessagingResponse.new { |resp| resp.message(body: "Deleted your alert for 20252.") }
        assert_equal expected_response.to_s, @response.body
        assert_empty User.where(phone: "+11235551283", zip: 20252)
        assert_not_empty User.where(phone: "+11235551283", zip: 94107)
    end

    test "returns help message for unknown input" do
        user_count = User.where(phone: "+11235551283").count
        post '/users/delete', params: { "From": "+11235551283", "Body": "Doh!"}
        assert_response :success

        expected_response = Twilio::TwiML::MessagingResponse.new do |resp| 
            resp.message(body: "Reply STOP to unsubscribe. Reply DELETE ALL to delete all of your data, or DELETE followed by a ZIP code to delete your alert for a specific zip code.")
        end
        assert_equal expected_response.to_s, @response.body
        assert_equal user_count, User.where(phone: "+11235551283").count
    end
end