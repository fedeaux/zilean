class Api::ActivitiesController < Api::BaseController
  before_action :set_activity, only: [:update, :destroy]

  def index
    @activities = current_user.activities.roots
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.created_by = current_user
    @activity.save

    render :show
  end

  def update
    @activity.update activity_params
    render :show
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
