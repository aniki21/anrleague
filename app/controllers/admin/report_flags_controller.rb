class Admin::ReportFlagsController < AdminController

  # GET /admin/report_flags
  def index
    @flags = ReportFlag
    case params[:filter]
    when "all"
      @flags = @flags.all
    when "upheld"
      @flags = @flags.upheld
    when "rejected"
      @flags = @flags.rejected
    when "responded"
      @flags = @flags.responded
    else
      @flags = @flags.raised
    end

    @flags = @flags.paginate(page: page)
    @page_title = "Reported items"
  end
  
  # GET /admin/report_flags/:id
  def show
    @flag = ReportFlag.find_by_id(params[:id])
    if @flag.blank?
      flash[:error] = "Flag not found"
      redirect_to admin_report_flags_path and return
    end

    @other_flags = ReportFlag.where(reportee_type: @flag.reportee_type, reportee_id: @flag.reportee_id)

    @page_title = "View Flag | Reported items"
  end

  # GET /admin/report_flags/:id/respond
  def respond
    @flag = ReportFlag.find_by_id(params[:id])
    if @flag.blank?
      flash[:error] = "Flag not found"
      redirect_to admin_report_flags_path and return
    end

    @flag.response = params[:response]
    @flag.responder_id = current_user.id

    if @flag.may_respond?
      case params[:result]
      when "Uphold"
        @flag.uphold!
      when "Reject"
        @flag.reject!
      else
        @flag.errors.add(:base,"Invalid option")
        render action: :show and return
      end
      # notify reporter
      flash[:success] = "Response submitted"
      redirect_to admin_report_flags_path and return
    else
      @page_title = "View Flag | Reported items"
      render action: :show and return
    end
  end

end
