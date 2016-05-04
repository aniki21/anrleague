class LeagueMailer < ApplicationMailer

  # Game result
  def game_result(game)
    @game = game
    @emails = game.players.map(&:email).join(",")
    @subject = "[#{SITE_NAME}] Game result submitted"

    mail(to: "pacosgrove1@gmail.com", bcc: @emails, subject: @subject)
  end
end
