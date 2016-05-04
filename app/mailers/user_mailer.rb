class UserMailer < ApplicationMailer
  default from: "pacosgrove1@gmail.com"

  def confirm_register(user)
    @user = user
    mail(to: @user.email, subject: "[ANRLeagues] Registration successful"
  end
end
