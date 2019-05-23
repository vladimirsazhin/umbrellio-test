Rails.application.routes.draw do
  scope format: false do
    post 'posts/create', as: :create_post
    post 'posts/rate', as: :rate_post
    get 'posts/top', as: :top_posts

    get 'authors/with-same-ips'
  end
end
