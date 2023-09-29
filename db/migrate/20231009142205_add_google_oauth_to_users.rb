class AddGoogleOauthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string, after: :username
    add_column :users, :uid, :string, after: :provider
    add_column :users, :full_name, :string, after: :email
    add_column :users, :avatar_url, :string, after: :full_name

    add_index :users, [:provider, :uid], unique: true
  end
end
