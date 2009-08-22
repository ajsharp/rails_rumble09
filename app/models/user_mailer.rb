class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject << 'Please activate your new account'
    @body[:url] = "#{APP_CONFIG[:site_url]}/activate/#{user.activation_code}"
  end
  
  def generated_signup_notification(user, password)
    setup_email(user)
    @subject << "You've been assigned a task!"
    @body[:url] = "#{APP_CONFIG[:site_url]}/activate/#{user.activation_code}"
    @body[:password] = password
  end
  
  def activation(user)
    setup_email(user)
    @subject << 'Your account has been activated!'
    @body[:url] = APP_CONFIG[:site_url]
  end
  
  def friend_request(user, friend)
    setup_email(friend)
    @subject << 'New friend request.'
    @body[:user] = user
    @body[:friend] = friend
  end
  
  def generated_friend_request(user, friend)
    setup_email(friend)
    @subject << 'Your friend has requested that you join them!'
    @body[:user] = user
    @body[:friend] = friend
  end
  
  protected
  
  def setup_email(user)
    @recipients = "#{user.email}"
    @from = APP_CONFIG[:admin_email]
    @subject = "[#{APP_CONFIG[:site_name]}] "
    @sent_on = Time.now
    @body[:user] = user
  end
end
