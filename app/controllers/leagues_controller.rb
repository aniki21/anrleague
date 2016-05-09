class LeaguesController < ApplicationController
  before_filter :require_login, except: [:index,:show,:search]

  # GET /leagues
  def index
    case params[:t]
    when "online"
      @leagues = Liga.online
    when "offline"
      @leagues = Liga.offline
    else
      @leagues = Liga.all
    end
    @leagues = @leagues.paginate(page:page)
  end

  # GET /leagues/:id/:slug
  def show
    @league = Liga.find_by_id(params[:id])
    if params[:slug].blank?
      redirect_to show_league_path(@league.id,@league.slug) and return
    end
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to root_path and return
    end

    @season = @league.current_season

    @member = false
    @officer = false
    @games = []
     
    if logged_in?
      unless @season.blank?
        @games = Game.for_player_season(current_user.id,@season.id).unplayed.paginate(page: params[:page],per_page:5)
      end
      @member = current_user.member_of?(@league)
      @officer = current_user.liga_users.where(liga_id: @league.id, officer: true).any?
    end

    @page_title = @league.display_name
  end

  # GET /leagues/new
  def new
    @league = Liga.new(location_type:"online",privacy:"open",table_privacy:"public")
    @require_maps = true
  end
  
  # POST /leagues
  def create
    @league = Liga.new(liga_params)
    @league.owner_id = current_user.id
    if valid_recaptcha?
      if @league.save
        # Add this user to the league as an officer
        LigaUser.create(user_id:current_user.id, liga_id:@league.id, officer:true).approve!
        
        flash[:success] = "League created"
        redirect_to show_league_path(@league.id,@league.slug) and return
      end
    end
    @require_maps = true
    render action: :new and return
  end

  # GET /leagues/:id/edit
  def edit
    @league = Liga.find_by_id(params[:id])

    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    unless current_user.id == @league.owner_id
      flash[:error] = "You don't have permission to do that"
      redirect_to show_league_path(@league.id,@league.slug) and return
    end
    @require_maps = true
    @season = Season.new(league_id: @league.id)
    @current_season_id = @league.current_season.id rescue 0
  end

  # POST /leagues/:id
  def update
    @league = Liga.find_by_id(params[:id])

    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    unless current_user.id == @league.owner_id
      flash[:error] = "You don't have permission to do that"
      redirect_to show_league_path(@league.id,@league.slug) and return
    end

    if @league.update_attributes(liga_params)
      flash[:success] = "League updated"
      redirect_to show_league_path(@league.id,@league.slug) and return
    else
      @require_maps = true
      @season = Season.new(league_id: @league.id)
      @current_season_id = @league.current_season.id rescue 0

      flash.now[:error] = @league.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  # DELETE /league/:id
  def destroy
  end

  # GET /leagues/search
  def search
    if params[:q].length >= 3
      @leagues = Liga.search(params[:q]).paginate(page: page)
      render action: :index and return
    else
      flash[:error] = "Search queries must be longer than three characters"
      redirect_to :back and return
    end
  end

  private
  def liga_params
    params.require(:liga).permit(:display_name,:location_type,:online_location,:latitude,:longitude,:description_markdown,:privacy,:table_privacy)
  end
end
