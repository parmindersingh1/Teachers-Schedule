class SchedulesController < ApplicationController
  # skip_before_action :authenticate_user!, :only => [:get_events,:list_events]
  before_action :show_schedule, only: [:show]
  before_action :require_permission, only: [ :edit, :update, :destroy]
  skip_before_filter  :verify_authenticity_token
  
  def new
    @schedule = Schedule.new(:endtime => 1.hour.from_now)
    render :json => {:form => render_to_string(:partial => 'form')}
  end
  
  def create        
    schedule = Schedule.new(schedule_params)   
    respond_to do |format|    
        if schedule.save
          format.html {render :nothing => true}
          format.json { render :json => {:schedule=> schedule.to_json(:include => :user ), :success => true, :message => "Schedule Created Successfully" }}
          # redirect_to events_path
        else
          format.html  {render :text => schedule.errors.full_messages.to_sentence, :status => 422}
          format.json {render :json => { :success => false, :message => schedule.errors.full_messages} }
        end   
    end 
  end
  
  def index
    unless params[:user_id].nil?
      @user_id=params[:user_id]
    else
      @user_id=current_user.id
    end
    @user = User.find_by_id(@user_id)
  end
  
  
  def get_schedules
    @user_id=""
    unless params[:user_id].nil?
      @user_id=params[:user_id]
    else
      @user_id=current_user.id
    end 
    @schedules = Schedule.where("date >='#{Time.now.at_beginning_of_day.to_formatted_s(:db)}' and user_id=#{@user_id}" ).order('starttime ASC')
    
    schedules = [] 
    @schedules.each do |schedule|
      schedules << {:id => schedule.id, :title => schedule.title, :description => {:class_name =>schedule.class_name,:description => schedule.description || "No description here..."},
       :start => "#{DateTime.parse("#{schedule.date} #{schedule.starttime}")}", :end => "#{DateTime.parse("#{schedule.date} #{schedule.endtime}")}"}
    end
    
    respond_to do |format|
    format.html
    format.json { render :json => schedules }
    end   
  end
  
  
   def list_schedules    
    @user_id=""   
    unless schedule_params.blank? || schedule_params[:user_id].nil?
      @user_id=schedule_params[:user_id]
    else
      @user_id=current_user.id
    end
    @schedules= Schedule.where("date >='#{Time.now.at_beginning_of_day.to_formatted_s(:db)}' and user_id=#{@user_id}").order('starttime ASC')
    # @schedules=@events.paginate(:page => params[:page] || 1,:per_page => 20)
    
    render :partial=>"listschedules"    
    
  end
  
  def history
    @user=""
    unless params.nil? || params[:user_id].nil?
      @user=User.find_by_id(params[:user_id])
    else
      @user=current_user
    end
    @schedules= Schedule.where("user_id=#{@user.id} and date <'#{ Time.now.at_beginning_of_day.to_formatted_s(:db)}'").order(:date => :desc, :starttime => :asc)
  end
  
  
  def move
    @schedule = Schedule.find_by_id params[:id]
    if @schedule
      @schedule.starttime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@schedule.starttime))
      @schedule.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@schedule.endtime))
      
      @schedule.save
    end
    render :nothing => true
  end
  
  
  def resize
    @schedule = Schedule.find_by_id params[:id]
    if @schedule
      @schedule.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@schedule.endtime))
      @schedule.save
    end    
    render :nothing => true
  end
  
  def edit
    @schedule = Schedule.find_by_id(params[:id])
    render :json => { :form => render_to_string(:partial => 'edit_form') } 
  end
  
  def update
     @schedule = Schedule.find_by_id(params[:schedule][:id])
      @schedule.attributes = schedule_params
      @schedule.save
   
    render :nothing => true    
  end  
  
  def destroy  
    @schedule = Schedule.find_by_id(params[:id])  
      @schedule.destroy
   
    render :nothing => true   
  end
  
  
  
 
  
  def get_user_schedules
    @user=""
    unless schedule_params.nil? && schedule_params[:user_id].nil?
      @user=User.find_by_id(schedule_params[:user_id])
    else
      @user=current_user
    end
    @schedules= Schedule.where("user_id=#{@user.id} and date >='#{Time.now.at_beginning_of_day.to_formatted_s(:db)}'").order(:date => :asc, :starttime => :asc)
      
   render :json=>{:schedules=>@schedules.to_json(:include => :user ), :success=> true, :message=> "Success"}
     
  end
  
  def get_user_history_schedules
   @user=""
    unless params.nil? && params[:user_id].nil?
      @user=User.find_by_id(params[:user_id])
    else
      @user=current_user
    end
    @schedules= Schedule.where("user_id=#{@user.id} and date <'#{ Time.now.at_beginning_of_day.to_formatted_s(:db)}'").order(:date => :desc, :starttime => :asc)
   render :json=>{:schedules=>@schedules.to_json(:include => :user ), :success=> true, :message=> "Success"}
       
  end
  
  def show_schedule    
    @schedules= Schedule.where("user_id=#{@user_id}")
  end

  def update_json
      @schedule = Schedule.find_by_id(schedule_params[:id])
      @schedule.attributes = schedule_params
      if @schedule.save
        render :json=>{:schedule=>@schedule.to_json(:include => :user ), :success=> true, :message=> "Successfully Updated"}
      else
        render :json=>{ :success=> false, :message=> @schedule.errors.full_messages}
      end   
      
  end  
  
   def destroy_json 
    @schedule = Schedule.find_by_id(params[:id])  
      if @schedule.destroy
        render :json=>{:success=> true, :message=> "Successfully Deleted"}
      else
        render :json=>{ :success=> false, :message=> @schedule.errors.full_messages}
      end   
       
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      return params.require(:schedule).permit(:id, :title, :description, :date, :starttime, :endtime,:class_name, :commit_button,:user_id) unless params[:schedule].nil? || params[:schedule].empty?
      return [] 
    end
    
     def require_permission
    @schedule= Schedule.find(params[:id])
    unless current_user == @schedule.user || current_user.role == (ENV["ROLE_ADMIN"])
      redirect_to :back, notice: "you don't have previleges"
    #Or do something else here
    end
  end
end
