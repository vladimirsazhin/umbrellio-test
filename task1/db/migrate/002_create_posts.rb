Sequel.migration do
  change do
    create_table :posts do
      column :id, 'serial', primary_key: true
      column :author_id, 'bigint'
      column :title, 'character varying', null: false
      column :content, 'text', null: false
      column :author_ip, 'inet'
      column :ratings_sum, 'bigint', default: 0, null: false
      column :ratings_count, 'bigint', default: 0, null: false
      column :rating, 'decimal', default: 0, null: false

      foreign_key [:author_id], :users
      index [:author_ip, :author_id], name: :index_posts_on_author_ip_and_author_id
      index [Sequel.desc(:rating)], name: :index_posts_on_rating
    end
  end
end
