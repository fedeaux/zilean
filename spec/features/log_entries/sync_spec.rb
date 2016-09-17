require 'rails_helper'

feature "Sync between multiple LogEntry tables", js: true do
  given(:current_user) {
    create_or_find_user :user_ray
  }

  before :each do
    @today = Time.now.beginning_of_day
    @yesterday = @today - 1.day

    beginning_of_day = to_local_time @today

    @yesterdays_log_entry = create :log_entry, started_at: beginning_of_day - 21.hours, finished_at: beginning_of_day - 15.hours
    @both_days_log_entry = create :log_entry, started_at: beginning_of_day - 3.hours, finished_at: beginning_of_day + 3.hours
    @todays_log_entry = create :log_entry, started_at: beginning_of_day + 12.hours, finished_at: beginning_of_day + 15.hours

    @activity = create_or_find_activity :activity_sleep
  end

  background do
    sign_in_with(current_user.email, attributes_for(:user_ray)[:password] )
    visit '/'

    within log_entry_table_selector(@today) do
      find('.show-yesterday-table').click
    end
  end

  scenario "viewing both log tables" do
    within log_entry_table_selector(@today) do
      expect(page).not_to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).to have_css log_entry_list_item_selector @todays_log_entry
    end

    within log_entry_table_selector(@yesterday) do
      expect(page).to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).not_to have_css log_entry_list_item_selector @todays_log_entry
    end
  end

  scenario "deleting a log_entry that concerns only one day" do
    destroy_log_entry @yesterdays_log_entry, @yesterday

    within log_entry_table_selector(@today) do
      expect(page).not_to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).to have_css log_entry_list_item_selector @todays_log_entry
    end

    within log_entry_table_selector(@yesterday) do
      expect(page).not_to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).not_to have_css log_entry_list_item_selector @todays_log_entry
    end
  end

  scenario "deleting a log_entry that concerns both days" do
    destroy_log_entry @both_days_log_entry, @today

    within log_entry_table_selector(@today) do
      expect(page).not_to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).not_to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).to have_css log_entry_list_item_selector @todays_log_entry
    end

    within log_entry_table_selector(@yesterday) do
      expect(page).to have_css log_entry_list_item_selector @yesterdays_log_entry
      expect(page).not_to have_css log_entry_list_item_selector @both_days_log_entry
      expect(page).not_to have_css log_entry_list_item_selector @todays_log_entry
    end
  end

  scenario "recreating a log_entry that concerns both days" do
    destroy_log_entry @both_days_log_entry, @today
    create_log_entry('23:00', '23:50', @activity, @yesterday)

    @new_log_entry = LogEntry.all.order('created_at').last

    # within log_entry_table_selector(@yesterday) do
    #   expect(page).to have_css log_entry_list_item_selector @yesterdays_log_entry
    #   expect(page).to have_css log_entry_list_item_selector @new_log_entry
    # end

    # within log_entry_table_selector(@today) do
    #   expect(page).to have_css log_entry_list_item_selector @todays_log_entry
    #   expect(page).not_to have_css log_entry_list_item_selector @new_log_entry
    # end
  end
end
