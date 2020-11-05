require 'test_helper'
require 'sidekiq/testing'

class WildfireTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
  end

  # callbacks
  test "should send text to nearby users after created" do
    fire = Wildfire.new(initial_latitude: 37.270543, initial_longitude: -122.02305, calculated_acres: 1, incident_name: "test fire")
    assert_difference 'SendTextWorker.jobs.size' do
      fire.save
    end
  end

  test "should send text to nearby users after marked stale" do
    fire_one = wildfires(:one)
    assert_difference 'SendTextWorker.jobs.size' do
      fire_one.update(stale: true)
    end
  end

  # users_near_self
  test "should return nearby users to fire" do
    fire_two = wildfires(:two)
    expected_users = [users(:two)]
    assert_equal expected_users, fire_two.users_near_self, "Expected #{expected_users} but got #{fire_two.users_near_self}"
  end

  # fire_within_radius
  test "should return true for fire within radius" do
    fire_one = wildfires(:one)
    user_one = users(:one)
    assert fire_one.fire_within_radius(25, user_one.zip), "Reported fire was out of radius"
  end

  test "should return false for fire outside radius" do
    fire_one = wildfires(:one)
    user_two = users(:two)
    assert_not fire_one.fire_within_radius(25, user_two.zip), "Reported fire was in radius"
  end
end
