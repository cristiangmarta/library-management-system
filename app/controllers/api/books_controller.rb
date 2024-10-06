module Api
  class BooksController < ApplicationController
    before_action :set_book, only: [ :show, :update, :destroy ]
    before_action { authorize(Book) }

    def index
      @books = if params[:filter]
        Book.where("title LIKE ? or author LIKE ? or genre LIKE ?", *[ "%#{params[:filter]}%" ]*3)
      else
        Book.all
      end

      render json: @books
    end

    def create
      @book = Book.new(book_params)

      if @book.save
        render json: @book, status: :created
      else
        render json: @book.errors, status: :unprocessable_entity
      end
    end

    def show
      render json: @book
    end

    def update
      @book.assign_attributes(book_params)

      if @book.save
        render json: @book
      else
        render json: @book.errors, status: :unprocessable_entity
      end
    end

    def destroy
      unless @book.destroy
        render json: @book.errors, status: :unprocessable_entity
      end
    end

    private

    def book_params
      params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
    end

    def set_book
      @book = Book.find(params[:id])
    end
  end
end
