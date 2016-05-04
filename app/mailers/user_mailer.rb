class UserMailer < ApplicationMailer
  default from: "pacosgrove1@gmail.com"

  def confirm_register(user)
    @user = user
    @subject = "[ANRLeagues] Registration successful"
    mail(to: @user.email, subject: subject)
  end
end
