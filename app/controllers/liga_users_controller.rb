class LigaUsersController < ApplicationController
  before_filter :require_login

  # POST /leagues/:id/join
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
        LeagueMailer.membership_requested(@invitation).deliver_now!
        flash[:success] = "Your request to join #{league.display_name} has been submitted for review by the league organiser(s)"
      elsif league.open?
        league_user.approve!
        # email user and officers
        LeagueMailer.user_approved(@invitation).deliver_now!
        LeagueMailer.user_joined(@invitation).deliver_now!
        flash[:success] = "You are now a member of #{league.display_name}"
      end
    else
      flash[:error] = league_user.errors.full_messages.to_sentence
    end
    redirect_to league_path(league.id,league.slug) and return
  end

  # POST /leagues/:league_id/join/:id/approve
  def approve
    league = Liga.find_by_id(params[:league_id])
    unless league.blank?
      if league.user_is_officer?(current_user)
        request = fetch_request(params[:league_id],params[:id])
        if request.may_approve?
          # email user and officers
          request.approve!
          flash[:success] = "The request has been approved"
        end
        redirect_to edit_league_path(request.liga_id) and return
      else
        flash[:error] = "You don't have permission to do that"
        redirect_to league_path(league.id,league.slug) and return
      end
    else 
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
  end

  # DELETE /leagues/:league_id/join/:id
  def destroy
    request = fetch_request(params[:league_id],params[:id])
    unless request.blank?
      request.destroy
      flash[:success] = "The request has been deleted"
    else
      flash[:error] = "The requested membership could not be found"
    end
    redirect_to edit_league_path(params[:league_id]) and return
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

  # GET /leagues/:league_id/member/:id/promote
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

  # GET /leagues/:league_id/member/:id/demote
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
  end

  private
  def fetch_request(league_id,request_id)
    league = Liga.find_by_id(league_id)
    unless league.blank?
      if league.user_is_officer?(current_user)
        request = LigaUser.where(liga_id: league_id, id: request_id).first
        unless request.blank?
          return request
        else
          flash[:error] = "The specified request could not be found"
        end
        redirect_to edit_league_path(league.id)
      else
        flash[:error] = "You don't have permission to do that"
        redirect_to league_path(league.id,league.slug) and return
      end
    else
      flash[:error] = "The specified league could not be found"
      redirect_to leagues_path and return
    end
  end
end
