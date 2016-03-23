class AdminPanelController < ApplicationController
  # authorize_resource :class => false
  def users    
   if current_user.role == ENV["ROLE_ADMIN"]
        @users =User.all 
   else
        @users= Array(current_user)    
   end
   respond_to do |format|
    format.html 
    format.json {    
          render :json => {  :success => true, :data => @users}
     } 
    
    end 
  end

  def edit_role    
    @user=User.find_by_id(params[:user])
  end
  
  def update_role
    @user=User.find_by_id(params[:user_id])
    @role =params[:role]
    # @user.roles=@role
    # @user.save
    # @user.add_role @role.name
    # user.roles = params[:role_ids].present? ? Role.find_all_by_id(params[:role_ids]) : [ ]
    @user.update_attributes(:role => @role) unless @role.nil?
    redirect_to :action => "users"
  end
end
