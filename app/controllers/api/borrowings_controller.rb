module Api
  class BorrowingsController < ApplicationController
    before_action :set_borrowing, only: [ :show, :return ]
    before_action { authorize(Borrowing) }

    def index
      render json: policy_scope(Borrowing)
    end

    def create
      @borrowing = current_user.borrowings.build(borrowing_params)

      if @borrowing.save
        render json: @borrowing, status: :created
      else
        render json: @borrowing.errors, status: :unprocessable_entity
      end
    end

    def show
      render json: @borrowing
    end

    def return
      @borrowing.mark_returned!
      render json: @borrowing

    rescue StateMachines::InvalidTransition => err
      render json: { message: err.message }, status: :unprocessable_entity
    end

    private

    def borrowing_params
      params.require(:borrowing).permit(:book_id)
    end

    def set_borrowing
      @borrowing = policy_scope(Borrowing).find(params[:id])
    end
  end
end
