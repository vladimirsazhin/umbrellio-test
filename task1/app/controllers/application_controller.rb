class ApplicationController < ActionController::API
  rescue_from 'ActiveModel::ValidationError' do |exception|
    render json: { errors: exception.model.errors }, status: :unprocessable_entity
  end
end
