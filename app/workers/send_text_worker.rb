class SendTextWorker
    include Sidekiq::Worker

    require 'twilio-ruby'
    
    def perform(users)
        account_sid = ENV['TWILIO_ACCOUNT_SID']
        auth_token = ENV['TWILIO_AUTH_TOKEN']
        @client = Twilio::REST::Client.new(account_sid, auth_token)
        from_phone = ENV['TWILIO_FROM_PHONE']
        #check if user phone number is validated
        users.each do |user|
            #iterate through user's affected fires and send text for each fire
            begin
                message = @client.messages.create(
                                        body: 'Hi there!',
                                        from: from_phone,
                                        to: "fake"
                                )
            rescue Twilio::REST::TwilioError => e
                puts e
                next
            end
            #create WildfireTextAlertRecord
            puts "Sent #{message.sid} to #{user.phone}"
            WildfireTextAlert.create
        end
    end
end