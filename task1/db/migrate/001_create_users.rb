Sequel.migration do
  change do
    create_table :users do
      column :id, 'serial', primary_key: true
      column :login, 'character varying', null: false

      index [Sequel.function(:lower, :login)], unique: true, name: :index_users_on_lower_login
    end
  end
end
