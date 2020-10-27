class UsersController < ApplicationController
    def show
        @user = User.find(user_params)
    end

    def new
        @user = User.new
    end

    def create
        @user = User.find_by(user_params) || User.new(user_params)

        respond_to do |format|
            if @user.save
                format.json { render json: @user, status: :created, location: @user}
            else
                flash[:alert] = @user.errors.messages
                format.json { render json: @user.errors.messages, status: :unprocessable_entity}
            end
        end
    end

    private

    def user_params
        params.require(:user).permit(:id, :phone, :zip)
    end
end