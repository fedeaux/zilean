class Api::ActivitiesController < Api::BaseController
  before_action :set_activity, only: [:update, :destroy]

  def index
    @activities = current_user.activities.roots
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user

    if @activity.save
      render :show, status: :created
    else
      @errors = @activity.errors
      render 'shared/errors', status: :unprocessable_entity
    end
  end

  def update
    if @activity.update activity_params
      render :show
    else
      @errors = @activity.errors
      render 'shared/errors', status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    render nothing: true
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def activity_params
    params.require(:activity).permit(:name, :color, :parent_id)
  end
end
