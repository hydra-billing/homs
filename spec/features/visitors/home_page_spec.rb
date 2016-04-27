feature 'Home page', js: true do
  scenario 'visit the home page' do
    visit "#{orders_path}"
    expect(page).to have_content 'Sign in'
  end
end
