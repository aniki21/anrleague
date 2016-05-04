class LigaUsersController < ApplicationController
  before_filter :require_login

  # POST /leagues/:id/join
  def create
    league = Liga.find_by_id(params[:id])

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
    redirect_to league_path and return
  end
end
