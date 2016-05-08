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
        flash[:success] = "Your request to join #{league.display_name} has been submitted for review by the league organiser(s)"
      elsif league.open?
        league_user.approve!
        flash[:success] = "You are now a member of #{league.display_name}"
      end
    else
      flash[:error] = league_user.errors.full_messages.to_sentence
    end
    redirect_to league_path(league.id,league.slug) and return
  end

  # POST /leagues/:league_id/join/:id/approve
  def approve
    request = fetch_request(params[:league_id],params[:id])
    request.approve! if request.may_approve?
    flash[:success] = "The request has been approved"
    redirect_to edit_league_path(league.id)
  end

  # POST /leagues/:league_id/join/:id/reject
  def reject
  end

  # POST /leagues/:league_id/invite
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

    #render json: @invitation and return
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

    @invitation.user_id = current_user.id
    @invitation.accept!

    flash[:success] = "The invitation has been accepted"
    redirect_to league_path(@league.id,@league.slug) and return
  end

  # POST /leagues/:league_id/invite/:token/accept
  def dismiss
  end

  private
  def fetch_request(league_id,request_id)
    league = Liga.find_by_id(league_id)
    unless league.blank?
      if league.user_is_officer?(current_user)
        request = LigaUser.where(liga_id: league_id, id: request_id)
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
