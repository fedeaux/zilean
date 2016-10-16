class Api::LogEntriesController < Api::BaseController
  before_action :set_log_entry, only: [:destroy]

  def index
    if params[:day]
      @log_entries = current_user.log_entries.on_day Time.parse(params[:day])
    elsif params[:from] and params[:to]
      @log_entries = current_user.log_entries.on_period Time.parse(params[:from]), Time.parse(params[:to])
    else
      @log_entries = current_user.log_entries.today
    end
  end

  def create
    create_params = []

    if params[:log_entry].to_h.any?
      create_params = [log_entry_params]
    elsif params[:log_entries].to_a.any?
      create_params = log_entries_params[:log_entries]
    end

    create_params.each do |log_entry_attributes|
      log_entry_attributes[:user] = current_user
      LogEntry.create log_entry_attributes
    end

    head 200
  end

  def crop
    if params[:log_entries].to_a.any?
      log_entries_params[:log_entries].each do |log_entry_attributes|
        LogEntry.crop log_entry_attributes[:started_at], log_entry_attributes[:finished_at], current_user
      end

      head 200
    else
      head 400
    end
  end

  def destroy
    @log_entry.destroy
    render :show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_log_entry
    @log_entry = current_user.log_entries.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def log_entry_params
    params.require(:log_entry).permit(:name, :activity_id, :observations, :started_at, :finished_at)
  end

  def log_entries_params
    params.permit(log_entries: [:name, :activity_id, :observations, :started_at, :finished_at])
  end
end
