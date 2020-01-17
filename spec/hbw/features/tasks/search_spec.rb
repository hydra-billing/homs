feature 'Check searching in table with tasks', js: true do
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
      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', 'expired (3y past due)'],
          ['High', 'Other assigned task', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )

      fill_search_field('te')

      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', 'expired (3y past due)'],
          ['High', 'Other assigned task', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )
    end

    it 'with valid search request and clearing on cross click' do
      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', 'expired (3y past due)'],
          ['High', 'Other assigned task', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )

      fill_search_field('test')

      expect(search_field_text).to eq('test')
      expect(tasks_table_content).to eq(
        [
          ['High', 'Other assigned task', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )

      clear_search_field

      expect(search_field_text).to eq('')
      expect(tasks_table_content).to eq(
        [
          ['Medium', 'Assigned task', ' Test name', '—', 'expired (3y past due)'],
          ['High', 'Other assigned task', ' Test name', 'Some test description', '30 Jun 2016']
        ]
      )
    end

    it 'with clearing after tab changes' do
      fill_search_field('test')
      expect(search_field_text).to eq('test')

      click_on_tab 'Unassigned tasks (2)'

      expect(search_field_text).to eq('')
    end
  end
end
