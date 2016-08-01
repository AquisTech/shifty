
class CalendarController < ApplicationController
  
  def show 
    @worker=Worker.find(params[:id])
    if @worker && params[:secretslug]==@worker.secretslug
      cal=Icalendar::Calendar.new
      
      @worker.shifts.includes(:task).where(:shift_template_id=>nil).where("monday >= ?", Date.today.beginning_of_week).order('monday asc,day_of_week asc,start_time asc').each do |s|
        cal.event do |e|
          e.dtstart = s.date+ ((s.start_time.strftime("%H").to_i * 3600) + (s.start_time.strftime("%M").to_i * 60)).seconds
          e.dtend = s.date+ ((s.end_time.strftime("%H").to_i * 3600) + (s.end_time.strftime("%M").to_i * 60)).seconds
          e.location = "Red Emma's"
          e.summary = "Shift: #{s.task.name}"
          e.description = "Shift"
        end
      end


      send_data cal.to_ical,:type => "text/calendar", :disposition => "attachment", :filename => @worker.secretslug+".ics"
    else
      raise ActionController::RoutingError.new("Calendar not found!")
    end
  end
  
end
