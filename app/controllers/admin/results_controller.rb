 class Admin::ResultsController < AdminController

   # GET /admin/results
   def index
     @results = Result.order("lower(display_name) ASC")
   end

   # POST /admin/results
   def create
     result = Result.new(result_params)
     if result.save
       flash[:success] = "Result saved"
     else
       flash[:error] = result.errors.full_messages.to_sentence
     end
     redirect_to admin_results_path and return
   end

   # GET /admin/results/:id/edit
   def edit
     @result = Result.find_by_id(params[:id])

     if @result.blank?
       flash[:error] = "The requested Game Result could not be found"
       redirect_to admin_results_path and return
     end
   end

   # POST /admin/results/:id
   def update
     result = Result.find_by_id(params[:id])

     if result.blank?
       flash[:error] = "The requested Game Result could not be found"
       redirect_to admin_results_path and return
     end

     if result.update_attributes(result_params)
       flash[:success] = "Result saved"
       redirect_to admin_results_path and return
     else
       flash[:error] = result.errors.full_messages.to_sentence
       redirect_to edit_admin_results_path and return
     end
   end

   # DELETE /admin/results/:id
   def destroy
     result = Result.find_by_id(params[:id])

     unless result.blank?
       flash[:success] = "Game Result '#{result.display_name}' has been deleted"
       result.destroy
     else
       flash[:error] = "The requested Game Result could not be found"
     end
     redirect_to admin_results_path and return
   end

   private
   def result_params
     params.require(:result).permit(:display_name,:winning_side)
   end

 end
