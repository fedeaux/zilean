require 'rails_helper'

feature "Create LogEntry from log entries table", js: true do
  given(:current_user) {
    create_or_find_user :user_ray
  }

  background do
    @activity = create_or_find_activity :activity_sleep
    sign_in_with(current_user.email, attributes_for(:user_ray)[:password] )
    visit '/'
  end

  scenario "viewing empty log table" do
    expect(page).to have_selector('.log-entries-table .cell', count: 144)
  end

  scenario "selecting cells" do
    select_cells from: '00:00', to: '01:50'

    expect(page).to have_css '#table-selection'

    within '#table-selection' do
      expect(page).to have_content(/12 selected cells/)
      expect(page).to have_css 'form'
    end
  end

  scenario "creating a log entry" do
    create_log_entry('01:00', '02:50', @activity)
    expect(LogEntry.count).to eq 1

    log_entry = LogEntry.first
    expect(log_entry.activity.id).to eq @activity.id

    expect(to_table_time(log_entry.started_at)).to eq '01:00'
    expect(to_table_time(log_entry.finished_at)).to eq '03:00'
  end
end
