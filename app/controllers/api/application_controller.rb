module Api
  class ApplicationController < ActionController::API
    include Pundit::Authorization

    before_action :authenticate_user!
    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :forbidden
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def forbidden(_exception)
      render json: { error: { message: "Access denied" } }, status: :forbidden
    end

    def record_not_found(_exception)
      render json: { error: { message: "Record not found" } }, status: :not_found
    end
  end
end
