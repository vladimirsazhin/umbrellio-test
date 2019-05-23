class AuthorsController < ApplicationController
  # GET /authors/with-same-ips
  def with_same_ips
    render json: GetAuthorsWithSameIps.new.call
  end
end
