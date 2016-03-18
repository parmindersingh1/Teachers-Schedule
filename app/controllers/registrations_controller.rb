class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token 
  def create

    respond_to do |format|
      format.html {
        super
      }
      format.json {
        @user = User.create(user_params)
        @user.save ? (render :json => { :success => true, :message => "User Created Successfully.", :data => @user }) : 
                     (render :json => {:success => false, :message => @user.errors.full_messages })
      }
    end
  end
  
 def update
   respond_to do |format|
     format.html {super}
     format.json {
       
       if @user.nil?  
        logger.info("User not found.")
        render :json => {  :success => false, 
            :message => "Invalid user id."
         } 
        else
          update_resource(@user, user_params)
          render :json => {  :success => true, 
           :data => @user, :message => "The user profile has been updated"
         } 
        end
     }
   
    end
    
  end

private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password, :first_name, :last_name, :mobile, :role)
    end    
    
    # def update_resource(resource, params)
      # resource.update_with_password(params)
    # end
   
  end 