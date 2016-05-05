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
  #   user_id   the User being invited
  def invite
  end

  # POST leagues/:league_id/join/:id/accept
  def accept
  end

  # POST /leagues/:league_id/join/:id/dismiss
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
