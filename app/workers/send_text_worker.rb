class SendTextWorker
    include Sidekiq::Worker

    require 'twilio-ruby'
    
    def perform(phone_with_msgs)
        account_sid = ENV['TWILIO_ACCOUNT_SID']
        auth_token = ENV['TWILIO_AUTH_TOKEN']
        @client = Twilio::REST::Client.new(account_sid, auth_token)
        from_phone = ENV['TWILIO_FROM_PHONE']
        phone_with_msgs.each do |phone, msg|
            begin
                message = @client.messages.create(
                                        body: msg,
                                        from: from_phone,
                                        to: phone
                                    )
            rescue Twilio::REST::TwilioError => e
                puts e
                next
            end
            puts "Sent #{message.sid} to #{phone}"
            # might need to rewrite this to call a webhook once you make it serverless
            # create WildfireTextAlert and also look it up before starting the job
            # FUCK i need the ids as well
            # WildfireTextAlert.create
        end
    end
end