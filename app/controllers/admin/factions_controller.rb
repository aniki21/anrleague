class Admin::FactionsController < AdminController

  def index
    @faction = Faction.new
    @factions = Faction.order(side: :asc, display_name: :asc).paginate(page:page)
  end

  def create
    @faction = Faction.new(faction_params)
    if @faction.save
      flash[:success] = "Faction created"
      redirect_to admin_factions_path and return
    else
      render action: :edit and return
    end
  end

  def edit
    @faction = Faction.find_by_id(params[:id])
    if @faction.blank?
      flash[:error] = "The requested faction could not be found"
      redirect_to admin_factions_path and return
    end
  end

  def update
    @faction = Faction.find_by_id(params[:id])
    if @faction.blank?
      flash[:error] = "The requested faction could not be found"
      redirect_to admin_factions_path and return
    end
    if @faction.update_attributes(faction_params)
      flash[:success] = "Faction updated"
      redirect_to admin_factions_path and return
    else
      render action: :edit and return
    end
  end

  private
  def faction_params
    params.require(:faction).permit(:display_name,:icon_style,:side)
  end
end
