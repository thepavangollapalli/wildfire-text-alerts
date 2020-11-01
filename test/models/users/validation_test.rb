require 'test_helper'

class ValidationTest < ActiveSupport::TestCase
  # validations
  test "should not save without any attributes" do
    user = User.new
    assert_not user.save, "Saved user without any attributes"
  end

  test "should not save without phone" do
    user = User.new(zip: "20205")
    assert_not user.save, "Saved user without phone number"
  end

  test "should not save non-us phone" do
    user = User.new(phone: "17108479267", zip: "20252")
    assert_not user.save, "Saved user with non-us phone"
  end

  test "should not save without zip" do
    user = User.new(phone: "382-555-1298")
    assert_not user.save, "Saved user without zip code"
  end

  test "should not save invalid zip" do
    user = User.new(phone:"382-555-1298", zip:99999)
    assert_not user.save, "Saved user with invalid zip"
  end

  test "should not save multiple users with same phone/zip" do
    user1 = User.new(phone: "(382) 555 1298", zip: "20252")
    assert user1.save, "Did not save valid user"
    user2 = User.new(phone: "(382) 555 1298", zip: "20252")
    assert_not user2.save, "Saved duplicate user"
  end

  test "should save valid US phone number in consistent format" do
    user = User.new(phone: "(382) 555 1298", zip: "20252")
    assert user.save, "Did not save user with valid us phone number"
    assert_equal "+13825551298", user.phone, "Did not save user phone in correct format"
  end
end