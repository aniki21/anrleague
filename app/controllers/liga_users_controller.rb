class LigaUsersController < ApplicationController
  before_filter :require_login

  # GET /leagues/:id/members
  def index
    @league = Liga.find_by_id(params[:league_id])
    @members = @league.liga_users

    @filter = (params[:filter] || "").downcase
    case @filter
    when "officers"
      @members = @members.officers
    when "pending"
      @members = @members.requested
    when "invited"
      @members = @members.invited
    when "approved"
      @members = @members.approved
    when "banned"
      @members = @members.banned
    else
      @members = @members.not_banned
      @filter = ""
    end
      
    unless params[:q].blank?
      users = User.where(id: @members.map(&:user_id), email: params[:q]).map(&:id)
      @members = @members.where(user_id: users)
    end

    @members = @members.order(officer: :desc, created_at: :asc).paginate(page:page)
    @page_title = "All Users | Manage League"
  end

  # POST /leagues/:id/members
  def create
    league = Liga.find_by_id(params[:league_id])

    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    if league.invitational?
      flash[:error] = "You can't request membership to an invitational league"
      redirect_to league_path(league.id,league.slug) and return
    end

    league_user = LigaUser.new(liga_id: league.id,user_id: current_user.id)
    if league_user.save
      if league.closed?
        # email officers
        LeagueMailer.membership_request(league_user).deliver_now!
        flash[:success] = "Your request to join #{league.display_name} has been submitted for review by the league organiser(s)"
      elsif league.open?
        league_user.approve!
        # email user and officers
        LeagueMailer.user_approved(league_user).deliver_now!
        LeagueMailer.user_joined(league_user).deliver_now!
        flash[:success] = "You are now a member of #{league.display_name}"
      end
    else
      flash[:error] = league_user.errors.full_messages.to_sentence
    end
    redirect_to league_path(league.id,league.slug) and return
  end

  # POST /leagues/:league_id/members/:id/approve
  def approve
    league = Liga.find_by_id(params[:league_id])
    unless league.blank?
      if league.user_is_officer?(current_user)
        membership = fetch_request(params[:league_id],params[:id])
        unless membership.blank?
          if membership.may_approve?
            # email user and officers
            membership.approve!
            flash[:success] = "The request has been approved"
          end
        else
          flash[:error] = "The membership request could not be found"
        end
        redirect_to edit_league_path(league.id) and return
      else
        flash[:error] = "You don't have permission to do that"
        redirect_to league_path(league.id,league.slug) and return
      end
    else 
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
  end

  # DELETE /leagues/:league_id/members/:id
  def destroy
    membership = fetch_request(params[:league_id],params[:id])
    unless membership.blank?
      league = membership.league

      unless membership.user_id == league.owner_id
        # delete unplayed games
        games = Game.where(league_id: membership.liga_id).where("runner_player_id = ? OR corp_player_id = ?",membership.user_id,membership.user_id)
        unplayed_games = games.unplayed
        unplayed_games.destroy_all
        cancelled_games = games.cancelled
        cancelled_games.destroy_all

        membership.destroy
        flash[:success] = "The specified membership has been removed"
      else
        flash[:error] = "You can't remove the owner from their own league"
      end

      if membership.league.user_is_officer?(current_user)
        redirect_to edit_league_path(params[:league_id]) and return
      else
        redirect_to league_path(league.id,league.slug) and return
      end
    else
      flash[:error] = "The specified membership could not be found"
    end
  end

  # POST /leagues/:league_id/invite
  # Send an invitation to join a league to an email address
  # PARAMS
  #   email   the email address to send the token to
  def invite
    league = Liga.find_by_id(params[:league_id])
    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    unless league.user_is_officer?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(league.id,league.slug)
    end

    if league.users.where(email: params[:email]).any?
      flash[:error] = "A user with that email address is already a member of this league"
      redirect_to edit_league_path(league.id,league.slug) and return
    end

    @invitation = LigaUser.new(liga_id:league.id)
    @invitation.invite

    if @invitation.save
      LeagueMailer.invite(params[:email],@invitation).deliver_now!
      flash[:success] = "An invitation to join this league has been sent to #{params[:email]}"
    else
      flash[:error] = invitation.errors.full_messages.to_sentence
    end
    redirect_to edit_league_path(league.id) and return
  end

  # GET leagues/:league_id/invite/:token
  def view_invite
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    @invitation = @league.liga_users.where(invitation_token: params[:token]).invited.first
    if @invitation.blank?
      flash[:error] = "The invitation specified has already been accepted or does not exist"
      redirect_to league_path(@league.id,@league.slug) and return
    end

    if logged_in? && current_user.member_of?(@league)
      @invitation.destroy
      flash[:info] = "You are already a member of this league"
      redirect_to league_path(@league.id,@league.slug) and return
    end
  end

  # POST /leagues/:league_id/invite/:token/accept
  def accept_invite
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    @invitation = @league.liga_users.where(invitation_token: params[:token]).invited.first
    if @invitation.blank?
      flash[:error] = "The invitation specified has already been accepted or does not exist"
      redirect_to league_path(@league.id,@league.slug) and return
    end

    @invitation.user_id ||= current_user.id
    @invitation.accept! if @invitation.may_accept?

    LeagueMailer.user_joined(@invitation).deliver_now!

    flash[:success] = "The invitation has been accepted"
    redirect_to league_path(@league.id,@league.slug) and return
  end

  # POST /leagues/:league_id/invite/:token/dismiss
  def dismiss
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    @invitation = @league.liga_users.where(invitation_token: params[:token]).invited.first
    if @invitation.blank?
      flash[:error] = "The invitation specified has already been accepted or does not exist"
      redirect_to league_path(@league.id,@league.slug) and return
    end

    @invitation.destroy

    flash[:success] = "The invitation has been removed"
    redirect_to league_path(@league.id,@league.slug) and return
  end

  # GET /leagues/:league_id/members/:id/promote
  def promote
    league = Liga.find_by_id(params[:league_id])
    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    # Only owners can promote
    unless league.user_is_owner?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to edit_league_path(league.id) and return
    end

    member = league.liga_users.where(id:params[:id]).approved.first
    if member.blank?
      flash[:error] = "The requested membership could not be found"
      redirect_to edit_league_path(league.id) and return
    end

    member.promote! if member.may_promote?
    flash[:success] = "Member promoted to officer"
    redirect_to edit_league_path(league.id) and return
  end

  # GET /leagues/:league_id/members/:id/demote
  def demote
    league = Liga.find_by_id(params[:league_id])
    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    # Only owners can promote
    unless league.user_is_owner?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to edit_league_path(league.id) and return
    end

    member = league.liga_users.where(id:params[:id]).approved.first
    if member.blank?
      flash[:error] = "The requested membership could not be found"
      redirect_to edit_league_path(league.id) and return
    end

    member.demote! if member.may_demote?
    flash[:success] = "Officer demoted to member"
    redirect_to edit_league_path(league.id) and return
  end

  # GET /leagues/:league_id/member/:id/ban
  def ban
    league = Liga.find_by_id(params[:league_id])
    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    # Only league officers can ban (maybe owners?)
    unless league.user_is_officer?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(league.id,league.slug)
    end
    
    member = league.liga_users.where(id:params[:id]).approved.first
    if member.blank?
      flash[:error] = "The requested membership could not be found"
      redirect_to edit_league_path(league.id) and return
    end

    member.ban! if member.may_ban?
    flash[:success] = "The requested member has been banned and will not be able to re-join the league"
    redirect_to edit_league_path(league.id)
  end

  # GET /league/:id/mambers/banned
  def banned
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    # Only league officers can ban (maybe owners?)
    unless @league.user_is_officer?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(@league.id,@league.slug)
    end

    @members = @league.liga_users.banned.paginate(page:page)
  end

  # GET /leagues/:league_id/members/:id/unban
  def unban
    league = Liga.find_by_id(params[:league_id])
    if league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
    
    # Only league officers can ban (maybe owners?)
    unless league.user_is_officer?(current_user)
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(league.id,league.slug)
    end
    
    member = league.liga_users.where(id:params[:id]).banned.first
    if member.blank?
      flash[:error] = "The requested membership could not be found"
      redirect_to edit_league_path(league.id) and return
    end

    member.unban! if member.may_unban?
    flash[:success] = "The requested member has been reinstated"
    redirect_to edit_league_path(league.id)
  end

  private
  def fetch_request(league_id,request_id)
    league = Liga.find_by_id(league_id)
    unless league.blank?
      membership_request = LigaUser.where(liga_id: league_id, id: request_id).first
      unless membership_request.blank?
        if league.user_is_officer?(current_user) || membership_request.user == current_user
          return membership_request
        end
      end
    end
    return nil
  end
end
