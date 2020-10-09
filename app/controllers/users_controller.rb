class UsersController < ApplicationController
    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            redirect_to @user
        else
            flash[:alert] = @user.errors.messages
            redirect_to new_user_path
        end
    end

    private

    def user_params
        params.require(:user).permit(:id, :phone, :zip)
    end
end