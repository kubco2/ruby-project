class EventsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_event, only: [:show, :edit, :update, :destroy, :subscribe, :unsubscribe]
  before_action :redirect_not_owned, only: [:edit, :update, :destroy]
  after_action :delete_unused_tags, only: [:update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @subscriptions = Subscription.joins(:event).where("subscriptions.user_id", current_user).index_by{ |s| s.event.id }
    @events = Event.where(nil)
    @events = @events.joins("LEFT JOIN subscriptions ON subscriptions.event_id = events.id")
      
    filtering_params(params).each do |key, value|
      @events = @events.public_send(key, value) if value.present?
    end
    @events = @events.where("subscriptions.user_id", current_user.id).where("subscriptions.state = ?", "yes") if params[:subscribed].present?
    @events = @events.where("subscriptions.user_id", current_user.id).where("subscriptions.state is null") if params[:invitations].present?
#    @events = @events.joins(:tags).where("tags.name" => params[:tag]) if params[:tag].present?
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user = current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    redirect_to events_path + "dsad"
    return 
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def subscribe
    redirect_to @event, alert: 'It is too late.' and return if @event.date_to <= Time.now
    subscription = Subscription.where(:event => @event, :user => current_user).first
    if subscription.nil?
      subscription = Subscription.new(:event => @event, :state => "yes", :user => current_user)
    else
      subscription.update(:state => "yes")
    end
    if subscription.save
      redirect_to @event, notice: 'Successfully subscribed to this event.' 
    else
      redirect_to @event, alert: 'Cannot subscribe to this event.'
    end
  end

  def unsubscribe
    redirect_to @event, alert: 'It is too late.' and return if @event.date_to <= Time.now
    subscription = Subscription.where(:event => @event, :user => current_user).first
    if subscription.nil?
      subscription = Subscription.new(:event => @event, :state => "no", :user => current_user)
    else
      subscription.update(:state => "no")
    end
    if subscription.save
      redirect_to @event, notice: 'Successfully unsubscribed from this event.' 
    else
      redirect_to @event, alert: 'Cannot unsubscribe from this event.'
    end
  end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:date_at, :date_to, :title, :description, :tags_string, :place_string)
    end

    def filtering_params(params)
      params.slice(:date_at, :date_to, :title, :tag, :place, :user_id, :upcoming)
    end

    def redirect_not_owned
      redirect_to @event, alert: "Only owner can edit or delete event." if @event.user != current_user
    end

    def delete_unused_tags
      ActiveRecord::Base.connection.execute(
        "delete from tags where id in(
          select t.id from tags as t left join events_tags as pt on pt.tag_id = t.id where pt.tag_id is null
        )"
      )
    end
end
