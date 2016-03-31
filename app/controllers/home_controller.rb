class HomeController < ApplicationController
  def index
    d = Time.now
    @today_schedules = Schedule.where("date = '#{d.at_beginning_of_day.to_formatted_s(:db)}'  and user_id=#{current_user.id}" )
    puts "=======#{@today_schedules.count}"
  end
end
