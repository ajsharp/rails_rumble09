require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "a valid User" do
    should "have a valid Factory" do
      assert Factory.build(:user).valid?
      assert Factory(:user).save
    end
  end # end of a valid User
  
end
