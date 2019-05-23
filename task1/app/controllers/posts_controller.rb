class PostsController < ApplicationController
  # POST /posts
  def create
    render json: CreatePost.new(params.permit(:title, :content, :author_login, :author_ip)).call
  end

  # POST /posts/rate
  def rate
    render json: RatePost.new(params.permit(:post_id, :value)).call
  end

  # GET /posts/top
  def top
    render json: GetTopPosts.new(params.permit(:n)).call
  end
end
