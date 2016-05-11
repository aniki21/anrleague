class UserMailer < ApplicationMailer

  # Send a notification on registration
  def confirm_register(user)
    @user = user
    @subject = "[#{SITE_NAME}] Registration successful"
    mail(to: @user.email, subject: @subject)
  end

  # Send the password reset link
  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(@user.reset_password_token)
    @subject = "[#{SITE_NAME}] Password reset request"
    mail(to: @user.email, subject: @subject)
  end

  # Notify the user of a password change
  def password_updated(user)
    @user = user
    @subject = "[#{SITE_NAME}] Your password has been changed"
    mail(to: @user.email, subject: @subject)
  end

  # Notify the user of an email address change
  def email_updated(user,old_email)
    @user = user
    @old_email = old_email
    @subject = "[#{SITE_NAME}] Your email address has been updated"
    mail(to: [@old_email,@user.email].join(","), subject: @subject)
  end
end
