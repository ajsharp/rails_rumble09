class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # only send the activation email if it's not a generated user
    UserMailer.deliver_signup_notification(user) if user.not_using_openid? && !user.generated
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated? && user.not_using_openid? && !user.generated
  end
end
