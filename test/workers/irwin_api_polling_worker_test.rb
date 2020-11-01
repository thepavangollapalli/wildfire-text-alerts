require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

class IrwinApiPollingWorkerTest < ActiveSupport::TestCase
    test "ignores nil values in response row when inserting" do
    end

    test "creates new wildfire record when none exists" do
    end

    test "updates existing wildfire record if present" do
    end
    
    test "marks db rows not in response as stale" do
    end
end