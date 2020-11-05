class SendTextWorker
    include Sidekiq::Worker

    require 'twilio-ruby'
    
    def perform(users)
        account_sid = ENV['TWILIO_ACCOUNT_SID']
        auth_token = ENV['TWILIO_AUTH_TOKEN']
        # byebug
        # raise 'Environment variables not present' unless account_sid && auth_token
        @client = Twilio::REST::Client.new(account_sid, auth_token)
        from_phone = ENV['TWILIO_FROM_PHONE']
        users.each do |user|
            begin
                msgs = user["msg"]
                user_id = user["user_id"]
                user_zip = user["user_zip"]
                user_phone = user["phone"]
                msgs.each do |msg|
                    msg_hash = msg.hash
                    if existing_msg = WildfireTextAlert.find_by(user_id: user_id, zip: user_zip, msg_hash: msg_hash)
                        puts "Already sent text to #{user_phone} in #{user_zip} at #{existing_msg.text_sent_at}"
                        next
                    end
                    message = @client.messages.create(
                                            body: msg,
                                            from: from_phone,
                                            to: user_phone
                                        )
                    WildfireTextAlert.create(user_id: user_id, msg_hash: msg_hash, zip: user_zip, text_sent_at: DateTime.now)
                    puts "Sent #{message.sid} to #{user_phone}"
                end
            rescue Twilio::REST::TwilioError => e
                puts e
                next
            end
        end
    end
end