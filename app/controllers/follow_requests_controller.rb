class FollowRequestsController < ApplicationController
  before_action :set_follow_request, only: %i[ show edit update destroy ]

  before_action :is_an_authenticated_user, only: [ :create, :destroy ]


  def is_an_authenticated_user
    if action_name == 'create'
      existing_request = FollowRequest.find_by(sender: current_user, recipient_id: params[:follow_request][:recipient_id])
      if existing_request && existing_request.accepted?
        redirect_back(fallback_location: root_url, alert: "You are already following this user.")
      end
    end
  end
  # GET /follow_requests or /follow_requests.json
  def index
    @follow_requests = FollowRequest.all
  end

  # GET /follow_requests/1 or /follow_requests/1.json
  def show
  end

  # GET /follow_requests/new
  def new
    @follow_request = FollowRequest.new
  end

  # GET /follow_requests/1/edit
  def edit
  end

  # POST /follow_requests or /follow_requests.json
  def create
    @follow_request = FollowRequest.new(follow_request_params)
    @follow_request.sender = current_user

    respond_to do |format|
      if @follow_request.save
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully created." }
        format.json { render :show, status: :created, location: @follow_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /follow_requests/1 or /follow_requests/1.json
  def update
    respond_to do |format|
      if @follow_request.update(follow_request_params)
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully updated." }
        format.json { render :show, status: :ok, location: @follow_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @follow_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follow_requests/1 or /follow_requests/1.json
  def destroy
    # Ensure the current user is the sender of the follow request before destroying it
    if @follow_request.sender == current_user
      @follow_request.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: root_url, notice: "Follow request was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_url, alert: "You can only delete your own follow requests." }
        format.json { render json: { error: "Not authorized" }, status: :unauthorized }
      end
    end
  end

  def unfollow
    # Ensure the current user is the sender and the request is accepted
    if @follow_request.sender == current_user && @follow_request.accepted?
      @follow_request.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: root_url, notice: "You have unfollowed the user." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_url, alert: "You can only unfollow users you are following." }
        format.json { render json: { error: "Not authorized" }, status: :unauthorized }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_follow_request
      @follow_request = FollowRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def follow_request_params
      params.require(:follow_request).permit(:recipient_id, :sender_id, :status)
    end
end
