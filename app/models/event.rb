class Event < ActiveRecord::Base
  belongs_to :event_series
  belongs_to :user
  
  attr_accessor  :commit_button
   validates_presence_of :title, :description, :user_id
  validate :validate_timings  
 
  
  
  def validate_timings
    if (starttime >= endtime)
      errors[:base] << "Start Time must be less than End Time"
    end
  end
  

  
end
