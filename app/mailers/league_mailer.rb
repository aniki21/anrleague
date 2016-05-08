class LeagueMailer < ApplicationMailer

  # Game result
  def game_result(game)
    @game = game
    emails = game.players.map(&:email).join(",")
    @subject = "[#{SITE_NAME}] Game result submitted"

    mail(to: DEFAULT_FROM_ADDRESS, bcc: emails, subject: @subject)
  end

  # Send invitation
  def invite(email,liga_user)
    @league = liga_user.league
    @token = liga_user.invitation_token
    @subject = "[#{SITE_NAME}] Invitation to join #{@league.display_name}"
    mail(to: email, subject: @subject)
  end
end
