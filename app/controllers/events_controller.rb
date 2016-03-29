class EventsController < ApplicationController
  # skip_before_action :authenticate_user!, :only => [:get_events,:list_events]
  before_action :set_event, only: [:show]
  before_action :require_permission, only: [ :edit, :update, :destroy]
  skip_before_filter  :verify_authenticity_token
  
  def new
    @event = Event.new(:endtime => 1.hour.from_now)
    render :json => {:form => render_to_string(:partial => 'form')}
  end
  
  def create        
    event = Event.new(event_params)   
    respond_to do |format|    
        if event.save
          format.html {render :nothing => true}
          format.json { render :json => {:event=> event.to_json(:include => :user ), :success => true, :message => "Schedule Created Successfully" }}
          # redirect_to events_path
        else
          format.html  {render :text => event.errors.full_messages.to_sentence, :status => 422}
          format.json {render :json => { :success => false, :message => event.errors.full_messages} }
        end    
    format.json 
    end 
  end
  
  def index
    unless params[:user_id].nil?
      @user_id=params[:user_id]
    else
      @user_id=current_user.id
    end
  end
  
  
  def get_events
    @user_id=""
    unless params[:user_id].nil?
      @user_id=params[:user_id]
    else
      @user_id=current_user.id
    end 
    @events = Event.where("date >= '#{DateTime.parse(params['start']).to_formatted_s(:db)}' and date <= '#{DateTime.parse(params['end']).to_formatted_s(:db)}' and user_id=#{@user_id}" )
    
    events = [] 
    @events.each do |event|
      events << {:id => event.id, :title => event.title, :description => {:location =>event.location,:description => event.description || "No description here..."},
       # :start => "#{event.starttime.iso8601}", :end => "#{event.endtime.iso8601}"}
       :start => "#{DateTime.parse("#{event.date} #{event.starttime}")}", :end => "#{DateTime.parse("#{event.date} #{event.endtime}")}"}
    end
    
    respond_to do |format|
    format.html
    format.json { render :json => events }
    end
    # render :text => events.to_json
  end
  
  
  
  def move
    @event = Event.find_by_id params[:id]
    if @event
      @event.starttime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@event.starttime))
      @event.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@event.endtime))
      
      @event.save
    end
    render :nothing => true
  end
  
  
  def resize
    @event = Event.find_by_id params[:id]
    if @event
      @event.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:hour_delta].to_i).hours.from_now(@event.endtime))
      @event.save
    end    
    render :nothing => true
  end
  
  def edit
    @event = Event.find_by_id(params[:id])
    render :json => { :form => render_to_string(:partial => 'edit_form') } 
  end
  
  def update
     @event = Event.find_by_id(params[:event][:id])
      @event.attributes = event_params
      @event.save
   
    render :nothing => true    
  end  
  
  def destroy  
    @event = Event.find_by_id(params[:id])  
      @event.destroy
   
    render :nothing => true   
  end
  
  # def get_dateupto
    # render :partial => "dateupto", :locals => { :f => f }
  # end
  
  def list_events    
    @user_id=""   
    unless event_params.blank? || event_params[:user_id].nil?
      @user_id=event_params[:user_id]
    else
      @user_id=current_user.id
    end
    @events= Event.where("user_id=#{@user_id}").order('starttime DESC')
    @events=@events.paginate(:page => params[:page] || 1,:per_page => 20)
    
    render :partial=>"listevents"
    
    
    # render :layout => false
  end
  
  def get_user_schedules
    d = Time.now
    @user=""
    unless event_params.nil? && event_params[:user_id].nil?
      @user=User.find_by_id(event_params[:user_id])
    else
      @user=current_user
    end
    @events= Event.where("user_id=#{@user.id} and date >='#{d.at_beginning_of_day.to_formatted_s(:db)}'").order(:date => :asc, :starttime => :asc)
      
   render :json=>{:events=>@events.to_json(:include => :user ), :success=> true, :message=> "Success"}
   # render :json=>{:events=>@events, :success=> true, :message=> "Success"}
     
  end
  
  def get_user_history_schedules
    d = Time.now
    @user=""
    unless params.nil? && params[:user_id].nil?
      @user=User.find_by_id(params[:user_id])
    else
      @user=current_user
    end
    @events= Event.where("user_id=#{@user.id} and date <'#{d.at_beginning_of_day.to_formatted_s(:db)}'").order(:date => :desc, :starttime => :asc)
      puts "========++#{@events.to_json}"
   render :json=>{:events=>@events.to_json(:include => :user ), :success=> true, :message=> "Success"}
   # render :json=>{:events=>@events, :success=> true, :message=> "Success"}
     
  end
  
  def show_schedule    
    @events= Event.where("user_id=#{@user_id}")
  end

  def update_json
      @event = Event.find_by_id(event_params[:id])
      @event.attributes = event_params
      if @event.save
        render :json=>{:event=>@event.to_json(:include => :user ), :success=> true, :message=> "Successfully Updated"}
      else
        render :json=>{ :success=> false, :message=> @event.errors.full_messages}
      end   
      
  end  
  
   def destroy_json 
    @event = Event.find_by_id(params[:id])  
      if @event.destroy
        render :json=>{:success=> true, :message=> "Successfully Deleted"}
      else
        render :json=>{ :success=> false, :message=> @event.errors.full_messages}
      end   
       
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      return params.require(:event).permit(:id, :title, :description, :date, :starttime, :endtime, :all_day, :location, :commit_button,:user_id) unless params[:event].empty?
      return [] 
    end
    
     def require_permission
    @event = Event.find(params[:id])
    unless current_user == @event.user || current_user.role == (ENV["ROLE_ADMIN"])
      redirect_to :back, notice: "you don't have previleges"
    #Or do something else here
    end
  end
end
