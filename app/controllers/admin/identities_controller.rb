class Admin::IdentitiesController < AdminController
  before_filter :load_factions

  # GET /admin/identities
  def index
    @identities = Identity.includes(:faction).order("factions.side ASC, factions.display_name ASC, identities.display_name ASC")
    @identity = Identity.new
  end

  # POST /admin/identities
  def create
    @identity = Identity.new(identity_params)
    if @identity.save
      flash[:success] = "Identity saved"
      redirect_to admin_identities_path and return
    else
      render action: :edit and return
    end
  end

  # GET /admin/identity/:id/edit
  def edit
    @identity = Identity.find_by_id(params[:id])
    if @identity.blank?
      flash[:error] = "The requested identity could not be found"
      redirect_to admin_identities_path and return
    end
  end

  # POST /admin/identity/:id
  def update
    @identity = Identity.find_by_id(params[:id])
    if @identity.blank?
      flash[:error] = "The requested identity could not be found"
      redirect_to admin_identities_path and return
    end
    if @identity.update_attributes(identity_params)
      flash[:success] = "Identity saved"
      redirect_to admin_identities_path and return
    else
      render action: :edit and return
    end
  end

  # DELETE /admin/identity/:id
  def destroy
    identity = Identity.find_by_id(params[:id])
    unless identity.blank?
      flash[:success] = "The identity <span class=\"nr nr-#{identity.icon_style}\"> #{identity.display_name}</span> was deleted"
      identity.destroy
    else
      flash[:error] = "The requested identity could not be found"
    end
    redirect_to admin_identities_path and return
  end

  private
  def load_factions
    @factions = Faction.order(side: :asc, display_name: :asc).map{|f| [f.display_name,f.id] }
  end

  def identity_params
    params.require(:identity).permit(:display_name,:faction_id,:nrdb_id,:short_name)
  end
end
