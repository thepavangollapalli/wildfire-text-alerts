require 'test_helper'
require 'sidekiq/testing'

class GeneralTest < ActiveSupport::TestCase
  # callbacks
  test "should call SendTextWorker after creation" do
    user = User.new(phone: "(382) 555 1298", zip: "20252")
    assert_difference 'SendTextWorker.jobs.size' do
      user.save
    end
  end

  # nearby_fires
  test "should return correct fires near user" do
    two = users(:two)
    fire_two = wildfires(:two)
    fire_three = wildfires(:three)
    expected_fires = [fire_two, fire_three]
    assert_equal expected_fires, two.nearby_fires, "Returned #{two.nearby_fires} instead of #{expected_fires}"
  end
end
