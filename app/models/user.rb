class User < ApplicationRecord
    require 'twilio-ruby'
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    has_many :wildfires, through: :wildfire_text_alerts

    # validation for phone number, zip code

    # callback to trigger validation for user phone number
    def register_phone
        byebug
        validation_request = @client.validation_requests
                            .create(
                               friendly_name: self.phone_number,
                               phone_number: self.phone_number
                            )
        #what are all the ways this can fail? handle them before setting active to true
        puts validation_request.friendly_name
        self.update(active: true)
    end

    # callback to send texts for all fires in area
    def send_current_fires
        SendTextWorker.perform_async(self)
    end

    # helper method for all fires that affect a user
    def affected_fires

    end
end
