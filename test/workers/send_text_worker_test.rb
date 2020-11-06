require 'test_helper'
require 'sidekiq/testing'

class SendTextWorkerTest < ActiveSupport::TestCase
    setup do
        Sidekiq::Testing.inline!
    end

    test "creates wildfiretextalert record after message sent" do
        user_one = users(:one)
        # 2 intro messages + number of nearby fires
        expected_diff = user_one.nearby_fires.count + 2
        assert_difference 'WildfireTextAlert.where(user_id: user_one.id).count', expected_diff do
            SendTextWorker.perform_async([user_one.to_h(:user_created)])
        end
    end

    test "skips and prints output when message already sent" do
        user_one = users(:one)
        SendTextWorker.perform_async([user_one.to_h(:user_created)])
        assert_output(/Already sent text/) do
            SendTextWorker.perform_async([user_one.to_h(:user_created)])
        end
    end

    test "prints any caught errors out" do
        stub_request(:post, /api\.twilio\.com\/2010-04-01\/Accounts\/(.+)?\/Messages.json/)
        .to_return(status: 400, body: "", headers: {})
        user_one = users(:one)
        assert_output(/\[HTTP 400\]/) do
            SendTextWorker.perform_async([user_one.to_h(:user_created)])
        end
    end
end