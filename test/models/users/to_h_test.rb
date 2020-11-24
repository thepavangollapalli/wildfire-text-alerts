require 'test_helper'

class ToHTest < ActiveSupport::TestCase
  test "should raise exception when msg type not passed in" do
    one = users(:one)
    assert_raises "msg_type not passed in" do
      one.to_h
    end
  end

  test "should raise exception when fire not passed in for fire_started" do
    one = users(:one)
    assert_raises "fire not passed in (msg_type: fire started)" do
      one.to_h(:fire_started)
    end
  end

  test "should return expected hash with fire started msg for fire_started" do
    one = users(:one)
    fire_one = wildfires(:one)
    expected_hash = {
                      phone: one.phone, 
                      msg: ["A new fire has been reported in your area: #{fire_one.to_s(one.zip)}"],
                      user_id: one.id, 
                      user_zip: one.zip
                    }
    actual_hash = one.to_h(:fire_started, fire_one)
    assert_equal(expected_hash, actual_hash, "Returned #{actual_hash}\n instead of #{expected_hash}")
  end

  test "should raise exception when fire not passed in for fire_ended" do
    one = users(:one)
    assert_raises "fire not passed in (msg_type: fire ended)" do
      one.to_h(:fire_ended)
    end
  end

  test "should return expected hash with fire ended msg for fire_ended" do
    one = users(:one)
    fire_one = wildfires(:one)
    expected_hash = {
                      phone: one.phone, 
                      msg: ["A fire has recently been marked as contained in your area: #{fire_one.to_s(one.zip)}"],
                      user_id: one.id, 
                      user_zip: one.zip
                    }
    actual_hash = one.to_h(:fire_ended, fire_one)
    assert_equal(expected_hash, actual_hash, "Returned #{actual_hash}\n instead of #{expected_hash}")
  end

  test "should return expected hash with multiple msgs for user_created" do
    two = users(:two)
    fire_two = wildfires(:two)
    fire_three = wildfires(:three)
    msgs = ["Hello! Thanks for signing up for wildfire text alerts.","There are 2 fires near you:", fire_two.to_s(two.zip), fire_three.to_s(two.zip)]
    expected_hash = {
                      phone: two.phone, 
                      msg: msgs,
                      user_id: two.id, 
                      user_zip: two.zip
                    }
    actual_hash = two.to_h(:user_created)
    assert_equal(expected_hash, actual_hash, "Returned #{actual_hash}\n instead of #{expected_hash}")
  end
end