feature 'Check searching in table with tasks', js: true do
  let(:first_task_due_date)  { DateTime.parse('2016-07-30T12:07:59').in_time_zone }
  let(:second_task_due_date) { DateTime.parse('2017-07-30T12:07:59').in_time_zone }

  let(:initial_tasks) do
    [
      ['Medium', 'Assigned task', ' Test name', '—', "expired (#{years_since(first_task_due_date)}y past due date)"],
      ['High', 'Other assigned task', ' Test name', 'Some test description', "expired (#{years_since(second_task_due_date)}y past due date)"],
      *Array.new(37) { ['High', 'Check test form', ' Test name', '—', '30 Jun 2016'] },
      ['High', 'Form for testing of field translations', ' Test translations', '—', '30 Jun 2016']
    ]
  end

  before(:each) do
    user = FactoryBot.create(:user)

    signin(user.email, user.password)
    expect(page).not_to have_content 'Sign in'
    expect(page).to     have_content 'Orders list'

    click_and_wait 'Tasks'
    expect_widget_presence
    expect(page).to have_content 'Open tasks'
  end

  describe 'search field rendered' do
    it 'with too short search query' do
      expect(tasks_table_content).to eq(initial_tasks)

      fill_search_field('te')

      expect(tasks_table_content).to eq(initial_tasks)
    end

    it 'with valid search request and clearing on cross click' do
      expect(tasks_table_content).to eq(initial_tasks)

      fill_search_field('test')

      expect(search_field_text).to eq('test')
      expect(tasks_table_content).to eq(
        [
          ['High', 'Other assigned task', ' Test name', 'Some test description', "expired (#{years_since(second_task_due_date)}y past due date)"]
        ]
      )

      clear_search_field

      expect(search_field_text).to eq('')
      expect(tasks_table_content).to eq(initial_tasks)
    end

    it 'with clearing after tab changes' do
      fill_search_field('test')
      expect(search_field_text).to eq('test')

      click_on_tab 'Unclaimed tasks (3)'

      expect(search_field_text).to eq('')
    end
  end
end
