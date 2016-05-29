class ApplicationMailer < ActionMailer::Base
  default from: "ANRLeagues <#{DEFAULT_FROM_ADDRESS}>"
  default to: "ANRLeagues <#{DEFAULT_FROM_ADDRESS}>"
  layout 'mailer'

  # Let a user know that their flag has been responded to
  def report_response_mailer(flag)
    @flag = flag

    @subject = "[#{SITE_NAME}] Your flag has received a response"
    mail(bcc: @flag.reporter.email, subject: @subject)
  end
end
