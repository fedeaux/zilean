require 'rails_helper'

feature "Manipulate log entries table", js: true do
  given(:current_user) {
    create_or_find_user :user_ray
  }

  background do
    @activity = create_or_find_activity :activity_work_project_x
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

  xscenario "creating a log entry" do
    select_cells from: '01:00', to: '02:50'

    within '#table-selection' do
      select_activity '#log_entry_activity_id', @activity.id
      find('.log-entries-selection-save').click
    end

    expect(page).to have_css '.log-entry-list'
  end
end
