class ResetUserPasswords < ActiveRecord::Migration[4.2]
  def change
    User.where(email: 'user@example.com').each do |user|
      user.update(password: 'changeme')
    end
  end
end
