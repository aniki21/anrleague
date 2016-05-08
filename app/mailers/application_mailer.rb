class ApplicationMailer < ActionMailer::Base
  default from: "ANRLeagues <#{DEFAULT_FROM_ADDRESS}>"
  layout 'mailer'
end
