Sequel.migration do
  change do
    create_table :ratings do
      column :id, 'serial', primary_key: true
      foreign_key :post_id, :posts, type: 'bigint'
      column :value, 'smallint', null: false

      index [:post_id], name: :index_ratings_on_post_id
      index [:value], name: :index_ratings_on_value
    end
  end
end
