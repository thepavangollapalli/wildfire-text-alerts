class User < ApplicationRecord
    has_many :wildfire_text_alerts

    validate :check_and_sanitize_phone
    validates :zip, presence: true, inclusion: { in: ZipToCoordsHelper::LOOKUP_HASH.keys, message: "is not a valid US zip code" }
    validates :phone, uniqueness: { scope: :zip, message: "can only be used once per zip"}

    after_create :send_current_fires

    def to_h(msg_type, fire = nil)
        fires = fire.present? ? [fire] : self.nearby_fires
        one_fire = fires.count == 1
        zero_fires = fires.count == 0
        msgs = []
        raise "msg_type not passed in" unless msg_type.present?
        case msg_type
        when :fire_started
            raise "fire not passed in for fire started msg type" unless fire.present?
            msgs << "A new fire has been reported in your area: #{fire.to_s(self.zip)}"
        when :fire_ended
            raise "fire not passed in for fire ended msg type" unless fire.present?
            msgs << "A fire has recently been marked as contained in your area: #{fire.to_s(self.zip)}"
        when :user_created
            msgs << "Hello! Thanks for signing up for wildfire text alerts."
            msgs << "There #{one_fire ? "is" : "are"} #{fires.count} #{one_fire ? "fire" : "fires"} near you#{zero_fires ? "." : ":"}"
            msgs += fires.map { |f| f.to_s(self.zip) }
        end
        {phone: self.phone.to_s, msg: msgs, user_id: self.id, user_zip: self.zip}
    end

    def send_current_fires
        SendTextWorker.perform_async([self.to_h(:user_created)])
    end

    def nearby_fires
        #turn into scope?
        Wildfire.nearby(25, self.zip)
    end

    private

    def check_and_sanitize_phone
        clean = true
        if self.phone.blank?
            errors.add(:phone, "can't be blank")
            clean = false
        end
        phone_regex = /\A(\+?1)?\s?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})\Z/
        match = phone_regex.match(self.phone)
        if match.nil?
            errors.add(:phone, "can only be a US phone number")
            clean = false
        end
        self.phone = "+1#{match[2]}#{match[3]}#{match[4]}" if clean
    end 
end
