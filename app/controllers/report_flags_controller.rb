class ReportFlagsController < ApplicationController
  before_filter :require_login
  
  # GET /report/:type/:id
  def new
    fetch_reportee
    # this is why we're glad everything has a #display_name attribute/function
    @page_title = "Reporting #{@reportee.display_name}"
  end

  # POST /report/:type/:id
  def create
    fetch_reportee

    unless valid_recaptcha?
      flash.now[:error] = "Invalid reCAPTCHA"
      render action: :new and return
    end    

    flag = ReportFlag.new(reporter: current_user, reportee: @reportee, description: params[:description])

    if flag.save
      flash[:success] = "Your report has been submitted"
      redirect_to @redirect and return
    else
      flash.now[:error] = flag.errors.full_messages.to_sentence
      render action: :new and return
    end
  end

  private
  def fetch_reportee
    if params[:type] == "leagues"
      klass = Liga
    elsif params[:type] == "users"
      klass = User
    else
      flash[:error] = "You don't have permission to do that"
      redirect_to root_path and return
    end

    @reportee = klass.find_by_id(params[:id])

    if @reportee.blank?
      flash[:error] = "The requested item could not be found"
      redirect_to root_path and return
    elsif @reportee == current_user
      flash[:error] = "You cannot report yourself"
      redirect_to root_path and return
    end

    @redirect = root_path
    case params[:type]
    when "leagues"
      @redirect = league_path(@reportee.id,@reportee.slug)
    when "users"
      @redirect = show_profile_path(@reportee.id,@reportee.slug)
    end
  end
end
