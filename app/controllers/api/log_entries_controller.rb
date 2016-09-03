class Api::LogEntriesController < Api::BaseController
  before_action :set_log_entry, only: [:destroy]

  def index
    if params[:day]
      @log_entries = current_user.log_entries.on_day Time.parse(params[:day]).in_time_zone(Time.zone).beginning_of_day
    else
      @log_entries = current_user.log_entries.today
    end
  end

  def create
    create_params = log_entry_params
    create_params[:user] = current_user

    @log_entries = Log_Entry.create create_params
    render :index
  end

  def destroy
    @log_entry.destroy
    render nothing: true
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_log_entry
    @log_entry = current_user.log_entries.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def log_entry_params
    params.require(:log_entry).permit(:name, :color, :parent_id)
  end
end
