class EventsController < ApplicationController
  respond_to :html, :json

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
    @event_coordinators = []
    @event_volunteers = []
    @event_waitlist = []
    @current_member_signed_up = Memevent.where(member_id: current_member.id, event_id: @event.id).length == 1
    @event.memevents.each do |memevent|
      @event_coordinators << memevent.member if memevent.member.is_admin?
      @event_volunteers << memevent.member if !memevent.member.is_admin and !memevent.waitlisted
      @event_waitlist << memevent.member if !memevent.member.is_admin and memevent.waitlisted
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.create!(params[:event])
  end

  def update
    @event.update_attributes(event_params)
  end

  def destroy
    @event.destroy
  end

  def remove_member
    @event = Event.where(id: params[:id])[0]
    if Time.now + 2.days <= @event.start_time
      Memevent.where(member_id: current_member.id, event_id: params[:id])[0].destroy
      flash[:error] = "You have been successfully removed from #{@event.event_name}."
    else
      flash[:error] = "You cannot automatically remove yourself inside a 48 hour window before the #{@event.event_name}. Please contact the LC lead for further instrucitons if you need to drop."
    end
    redirect_to events_index_path
  end

  def signup
    @event = Event.where(id: params[:id])[0]
    unless !permit_signup?(@event)
      if @event.memevents.length >= @event.num_volunteers
        waitlisted = 'true'
      else
        waitlisted = 'false'
      end
      Memevent.create(:event_id => @event.id, :member_id => current_member.id, :waitlisted => waitlisted, :date_added => Time.now.utc, :approved => 'true', :hours => @event.duration)
      waitlisted == 'true' ? flash[:error] = "You have been waitlisted for #{@event.event_name}. You'll receive an email notification if you are moved into the volunteer list." : flash[:error] = "You have successfully signed up for #{@event.event_name}."
    end
    redirect_to events_index_path
  end

  private
  def permit_signup?(event)
    if Memevent.where(member_id: current_member.id, event_id: event.id).length > 0
      flash[:error] = "You have already signed up for #{event.event_name}."
      false
    elsif Time.now > event.start_time
      flash[:error] = "The start time for #{event.event_name} has already passed."
      false
    else
      true
    end
  end
end