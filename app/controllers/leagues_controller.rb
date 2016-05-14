class LeaguesController < ApplicationController
  before_filter :require_login, except: [:index,:show,:search,:nearby,:search_api]

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

  def nearby
  end

  # GET /leagues/:id/:slug
  def show
    @league = Liga.find_by_id(params[:id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to root_path and return
    end
    unless params[:slug] == @league.slug
      redirect_to show_league_path(@league.id,@league.slug) and return
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

    unless @league.user_is_officer?(current_user)
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

    unless @league.user_is_officer?(current_user)
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

  #
  #
  #
  def new_broadcast
    @league = Liga.find_by_id(params[:id])
    if @league.blank?
      flash[:error] = "The specified league could not be found"
      redirect_to edit_league_path(@league.id) and return
    end
  end

  def create_broadcast
    @league = Liga.find_by_id(params[:id])
    unless @league.blank?
      message = params[:message].strip
      unless message.blank?
        flash[:success] = "Broadcast sent to #{@league.users.notify_league_broadcast.count} member(s)"
        LeagueMailer.broadcast(@league,message,current_user).deliver_now!
        redirect_to edit_league_path(@league.id) and return
      else
        flash.now[:error] = "Broadcast message cannot be blank"
        render action: :new_broadcast and return
      end
    else
      flash[:error] = "The specified league could not be found"
      redirect_to leagues_path and return
    end
  end

  def preview_broadcast
    unless params[:markdown].blank?
      render html: MARKDOWN.render(params[:markdown]).html_safe and return
    end
    render text: "" and return
  end


  #
  #
  #

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

  def search_api
    @leagues = Liga.all

    # Search by query
    unless params[:q].blank?
      if params[:q].length >= 3
        @leagues = @leagues.search(params[:q])
      else
        @leagues = []
      end
    end

    # Search by location type
    unless params[:t].blank?
      case params[:t]
      when "online"
        @leagues = @leagues.online
      when "offline"
        @leagues = @leagues.offline
      end
    end

    # Search by Coordinate and Radius
    unless params[:c].blank?
      origin = params[:o].split(",")
      centre = params[:c].split(",")
      radius = params[:r].blank? ? 15 : params[:r].to_i
      @leagues = @leagues.nearby(centre[0],centre[1],radius)
    end

    @leagues = @leagues.to_a unless @leagues.is_a?(Array)

    @leagues = @leagues.take(26);

    render json: @leagues.each_with_index.map{|l,i| { label: labels[i], id: l.id, display_name: l.display_name, url: league_url(l.id,l.slug), location:(l.offline? ? l.offline_location : ( l.online? ? "Online" : "Unknown" )), lat: l.latitude, lng: l.longitude, distance: l.distance_from(origin,units: :miles).round(1) } } and return
  end

  private
  def liga_params
    params.require(:liga).permit(:display_name,:location_type,:online_location,:latitude,:longitude,:description_markdown,:privacy,:table_privacy)
  end

  def labels
    %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  end
end
