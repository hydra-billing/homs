class AddAdmin < ActiveRecord::Migration
  def change
    User.connection.schema_cache.clear!
    User.reset_column_information

    existing_admin = User.find_by(email: 'user@example.com')

    unless existing_admin.present?
      User.create!(
        email: 'user@example.com',
        password: 'changeme',
        name: 'John',
        last_name: 'Doe',
        role: :admin,
        company: 'Example Corporation',
        department: 'Administrators',
        api_token: 'RENEWMEPLEASE')
    end
  end
end
