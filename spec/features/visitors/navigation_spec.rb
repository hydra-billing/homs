feature 'Navigation links', :devise, js: true do
  scenario 'view navigation links' do
    visit "#{orders_path}"
    expect(page).to have_content 'Sign in'
  end
end
