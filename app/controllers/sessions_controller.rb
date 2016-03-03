class SessionsController < Devise::SessionsController 
  skip_before_filter :verify_authenticity_token 
  skip_before_filter :require_no_authentication, :only => [:create ]
  def create
    respond_to do |format|  
      format.html { super }  
      format.json {  
        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")  
        render :json => {  :success => true, 
           :data => resource, :total => 1, :message => "Logged In"
         } 
      }
    end  
  end

  def destroy
    respond_to do |format|
      format.html {super}
      format.json {  
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        render :json => {:success => true, :message => "Logged Out"}
      }
    end
  end

  def failure
    puts "-------------"
    respond_to do |format|
    format.html {super}
    format.json {
      warden.custom_failure!
      render :json => {:success => false, :errors => ["Login Failed"], :message => "Login Failed"}
    }
  end
 end


end


