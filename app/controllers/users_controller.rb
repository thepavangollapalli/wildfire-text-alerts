class UsersController < ApplicationController
    require 'twilio-ruby'

    # need to implement security check for this
    skip_before_action :verify_authenticity_token, only: :delete

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

    def delete
        phone = params["From"]
        body = params["Body"].upcase

        # 2 reasons to return early:
        # if the msg is "start" - twilio responds to start as well
        # if the phone number doesn't exist in the db
        return head :ok if body.match(/\Astart\Z/i) || User.where(phone: phone).blank?

        # format of incoming text can be DELETE ALL or DELETE {zip}
        pattern = /\A(delete)[\ ]?(.*)\Z/i
        reqs = body.match(pattern)

        help_msg = "Reply STOP to unsubscribe. Reply DELETE ALL to delete all of your data, or DELETE followed by a ZIP code to delete your alert for a specific zip code."
        error_msg = "Sorry, there was a slight hiccup on our end. Please try again in a bit."
        twiml = Twilio::TwiML::MessagingResponse.new do |resp|
            if reqs && reqs[1] == "DELETE"
                if reqs[2] == "ALL"
                    clean = true
                    User.transaction do
                        begin
                            User.where(phone: phone).destroy_all
                        rescue
                            resp.message(body: error_msg)
                            clean = false
                        end
                    end
                    resp.message(body: "Deleted all data for #{phone}. Goodbye!") if clean
                elsif ZipToCoordsHelper::LOOKUP_HASH[reqs[2]].present?
                    clean = true
                    User.transaction do
                        begin
                            User.where(phone: phone, zip: reqs[2]).destroy_all
                        rescue
                            resp.message(body: error_msg)
                            clean = false
                        end
                    end
                    resp.message(body: "Deleted your alert for #{reqs[2]}.") if clean
                else
                    resp.message(body: help_msg)
                end
            elsif body == "42069"
                resp.message(body: "Nice")
            else
                resp.message(body: help_msg)
            end
        end

        render xml: twiml
    end

    private

    def user_params
        params.require(:user).permit(:id, :phone, :zip)
    end
end