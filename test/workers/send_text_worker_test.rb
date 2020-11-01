require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

class SendTextWorker < ActiveSupport::TestCase
    test "raises error if environment variable not present" do
    end
    test "creates wildfiretextalert record after message sent" do
    end
    test "skips and prints output when message already sent" do
    end
    test "prints any caught errors out" do
    end
end