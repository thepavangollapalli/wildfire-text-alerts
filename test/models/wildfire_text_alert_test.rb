require 'test_helper'

class WildfireTextAlertTest < ActiveSupport::TestCase
  test "should save record for first msg sent to user for zip" do
    user_one = users(:one)
    wildfire_alert = WildfireTextAlert.new(user_id: user_one.id, zip: user_one.zip, msg_hash: "test".hash)
    assert wildfire_alert.save, "Did not save valid wildfire text alert"
  end

  test "should not save duplicate record when hashed msg present" do
    user_one = users(:one)
    wildfire_alert = WildfireTextAlert.new(user_id: user_one.id, zip: user_one.zip, msg_hash: "test".hash)
    assert wildfire_alert.save, "Did not save valid wildfire text alert"
    wildfire_alert_2 = WildfireTextAlert.new(user_id: user_one.id, zip: user_one.zip, msg_hash: "test".hash)
    assert_not wildfire_alert_2.save, "Saved duplicate wildfire text alert"
  end
end
