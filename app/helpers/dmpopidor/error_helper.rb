module Dmpopidor
  module ErrorHelper
    def bad_request(message)
      render json: { status: 400, error: 'Bad Request', message: message }, status: :bad_request
    end

    def not_found(message)
      render json: { status: 404, error: 'Not Found', message: message }, status: :not_found
    end

    def forbidden(message)
      render json: { status: 403, error: 'Forbidden', message: message || 'You are not authorized to access this resource' }, status: :forbidden
    end

    def internal_server_error(message)
      render json: { status: 500, error: 'Internal Server Error', message: message }, status: :internal_server_error
    end
  end
end
