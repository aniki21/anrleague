class LeagueMailer < ApplicationMailer

  # Game result
  def game_result(game)
    @game = game
    users = game.league.officers.notify_officer_game_result
    users += game.players.notify_game_result
    
    emails = users.uniq.map(&:email).join(",")
    @subject = "[#{SITE_NAME}] Game result submitted"

    mail(to: DEFAULT_FROM_ADDRESS, bcc: emails, subject: @subject)
  end

  # Membership requested
  def membership_request(liga_user)
    @league = liga_user.league
    officers = @league.officers.notify_officer_league_membership.map(&:email).join(",")
    @user = liga_user.user
    @subject = "[#{SITE_NAME}] Membership requested"
    mail(to: DEFAULT_FROM_ADDRESS, bcc: officers, subject: @subject)
  end

  # Send invitation
  def invite(email,liga_user)
    @league = liga_user.league
    @token = liga_user.invitation_token
    @subject = "[#{SITE_NAME}] Invitation to join #{@league.display_name}"
    mail(to: DEFAULT_FROM_ADDRESS, bcc: email, subject: @subject)
  end

  # Notify officers of a new user joining their league
  def user_joined(liga_user)
    @league = liga_user.league
    @user = liga_user.user

    emails = @league.officers.notify_officer_league_membership.map(&:email).join(",")

    @subject = "[#{SITE_NAME}] New user joined #{@league.display_name}"
    mail(to: DEFAULT_FROM_ADDRESS, bcc: emails, subject: @subject)
  end

  # Notify user of membership acceptance
  def user_approved(liga_user)
    @league = liga_user.league
    @user = liga_user.user

    @subject = "[#{SITE_NAME}] You are now a member of #{@league.display_name}"
    mail(to: DEFAULT_FROM_ADDRESS, bcc: @user.email, subject: @subject)
  end

  # Broadcast message to all members
  def broadcast(league,message,sender,subject=nil)
    @league = league
    @sender = sender
    @message = MARKDOWN.render(message)

    subject = subject.blank? ? "Important information from #{@league.display_name}" : subject
    @subject = "[#{SITE_NAME}] #{subject}"

    ids = @league.liga_users.approved.map(&:user_id)
    bcc = User.where(id: ids).notify_league_broadcast.map{|u| "#{u.display_name} <#{u.email}>" }

    mail(to: DEFAULT_FROM_ADDRESS, bcc: bcc, subject: @subject)
  end
end
