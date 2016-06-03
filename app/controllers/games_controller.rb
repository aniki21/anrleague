class GamesController < ApplicationController

  # GET /leagues/:league_id/games
  def index
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    @season = Season.find_by_id(params[:season_id])
    if @season.blank?
      flash[:error] = "The requested season could not be found"
      redirect_to league_path(@league.id,@league.slug)
    end

    @games = Game.for_season(@season.id).order(result_id: :asc, created_at: :asc)
    @title = "All games"

    @games = @games.paginate(page: page)
  end

  # GET /leagues/:league_id/games/:id
  def show
    @game = Game.where(id:params[:id], league_id: params[:league_id]).first
    render layout: "iframe"
  end

  # GET /leagues/:league_id/games/:id/edit
  def edit
    @game = Game.where(id: params[:id], league_id: params[:league_id]).first

    unless @game.blank?
      if @game.user_can_update?(current_user)
        @runners = Identity.runner.order(display_name: :asc).map{|r| [r.display_name,r.id ] }
        @corps = Identity.corp.order(display_name: :asc).map{|c| [c.display_name,c.id ] }
        @results = Result.order("lower(display_name) ASC").map{|r| [r.full_display_name,r.id] }
      else
        if @game.result_id == 0
          flash.now[:error] = "You can't update the results for a cancelled game"
        else
          flash.now[:error] = "You don't have permission to do that"
        end
        render action: :update, layout: "iframe" and return
        #redirect_to league_path(@game.league_id) and return
      end
    else
      flash.now[:error] = "The requested game could not be found in the specified league"
      #redirect_to leagues_path and return
    end
    render layout: "iframe"
  end

  def update
    @game = Game.where(id: params[:id], league_id: params[:league_id]).first
    unless @game.blank?
      if @game.update_attributes(game_params)
        
        unless @game.result_id.blank?
          LeagueMailer.game_result(@game).deliver_now!
        end

        @game.season.update_table!
        flash[:success] = "Game saved"
        render layout: "iframe" and return
      else
        flash.now[:error] = @game.errors.full_messages.to_sentence
        render action: :edit and return
      end
    else
      flash[:error] = "The requested game could not be found"
      redirect_to league_path(@game.league) and return
    end
  end

  private
  def game_params
    params.require(:game).permit(
      :runner_identity_id,
      :runner_agenda_points,
      :runner_commentary,
      :corp_identity_id,
      :corp_agenda_points,
      :corp_commentary,
      :result_id
    )
  end

end
