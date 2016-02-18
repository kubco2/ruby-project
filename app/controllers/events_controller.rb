class EventsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_event, only: [:show, :edit, :update, :destroy, :subscribe, :unsubscribe, :invite]
  before_action :redirect_not_owned, only: [:edit, :update, :destroy]
  after_action :delete_unused_tags, only: [:update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @subscriptions = Subscription.joins(:event).where("subscriptions.user_id = ?", current_user.id).index_by{ |s| s.event.id }
    @events = Event.order(:date_at).order(:id).where(nil)

    @events = @events.joins("LEFT JOIN subscriptions ON subscriptions.event_id = events.id")
      
    filtering_params(params).each do |key, value|
      @events = @events.public_send(key, value) if value.present?
    end
    @events = @events.where("subscriptions.user_id = ?", current_user.id).where("subscriptions.state = ?", "yes") if params[:subscribed].present?
    @events = @events.where("subscriptions.user_id = ?", current_user.id).where("subscriptions.state = ?", "request") if params[:invitations].present?
    @events = @events.distinct
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @subscription = Subscription.where("user_id = ?", current_user.id).where("event_id = ?", @event.id).first
    @subscriptions = Subscription.where("event_id = ?", @event.id)
    @comments = Comment.where("event_id = ?", @event.id)
    @pictures = Picture.where("event_id = ?", @event.id)
    ids = @subscriptions.map { |s| s.user.id }
    @invite_users = User.where("id not in(?)", ids)
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
        Subscription.create(:event_id => @event.id, :user_id => current_user.id, :state => "yes").save
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
        upload_images 
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
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def subscribe
    redirect_to @event, alert: 'It is too late.' and return if @event.date_to <= Time.now
    subscription = Subscription.where("event_id = ?", @event.id).where("user_id = ?", current_user.id).first
    if subscription.nil?
      subscription = Subscription.new("event_id = ?", @event.id).where("state = ?", "yes").where("user_id = ?", current_user.id)
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
    subscription = Subscription.where("event_id = ?", @event.id).where("user_id = ?", current_user.id).first
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

  def invite
    redirect_to @event, alert: 'It is too late.' and return if @event.date_to <= Time.now
    params["people"].each do |value|
      Subscription.new(:event => @event, :sender_id => current_user.id, :user_id => value.to_i, :state => "request").save
    end
    redirect_to @event, notice: 'Invitations sent.'

  end

  def picture_del
    @picture = Picture.find(params[:picture])
    event = @picture.event
    redirect_to event_path(:id => event.id), alert: 'Only owner can delete pictures' and return if event.user != current_user
    @picture.destroy
    redirect_to edit_event_path(:id => event.id), notice: 'Successfully deleted picture'
  end

  def comment_del
    @comment = Comment.find(params[:comment])
    event = @comment.event
    redirect_to event_path(:id => event.id), alert: 'Only owner can delete comments' and return if event.user != current_user
    @comment.destroy
    redirect_to event_path(:id => event.id), notice: 'Successfully deleted comment'
  end

  def comment_add
    @comment = Comment.create(:user => current_user, :event_id => params[:event_id], :body => params[:body])
    @comment.save
    redirect_to event_path(:id => params[:event_id]), notice: 'Comment successfully added'
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

    def upload_images
      params.slice(:file1, :file2, :file3, :file4, :file5, :file6, :file7, :file8, :file9, :file10).each { |key, file|
        Picture.create(img: file, event: @event).save
      }
    end

    def delete_unused_tags
      ActiveRecord::Base.connection.execute(
        "delete from tags where id in(
          select t.id from tags as t left join events_tags as pt on pt.tag_id = t.id where pt.tag_id is null
        )"
      )
    end
end
