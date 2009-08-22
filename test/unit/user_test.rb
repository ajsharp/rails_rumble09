require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "a valid User" do
    should "have a valid Factory" do
      assert Factory.build(:user).valid?
      assert Factory(:user).save
    end
    
    should "not require the login field" do
      assert Factory(:user, :login => nil).valid?
    end
    
    should_validate_presence_of :email
    should_have_many :tasks, :assignments, :comments
  end # end of a valid User
  
end
