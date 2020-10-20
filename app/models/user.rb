class User < ApplicationRecord
    has_many :wildfire_text_alerts

    validates :phone, format: { with: /(\+1)[0-9]{10}/, message: "must include US country code (+1)" }
    validates :zip, inclusion: { in: ZipToCoordsHelper::LOOKUP_HASH.keys, message: "is not a valid US zip code" }
    validates :phone, uniqueness: { scope: :zip, message: "can only be used once per zip"}

    after_create :send_current_fires

    def to_h(msg_type, fire = nil)
        fires = fire.present? ? [fire] : self.nearby_fires
        one_fire = fires.count == 1
        zero_fires = fires.count == 0
        case msg_type
        when :fire_started
            raise "fire not passed in for fire started msg type" unless fire.present?
            msg = "A new fire has been reported in your area: #{fire.to_s}"
        when :fire_ended
            raise "fire not passed in for fire ended msg type" unless fire.present?
            msg = "A fire has recently been marked as over in your area: #{fire.to_s}"
        else
            msg = "There #{one_fire ? "is" : "are"} #{fires.count} #{one_fire ? "fire" : "fires"} near you#{zero_fires ? "." : ": "}" + fires.join(" ")
        end
        {phone: self.phone.to_s, msg: msg, user_id: self.id, user_zip: self.zip}
    end

    def send_current_fires
        SendTextWorker.perform_async([self.to_h(:user_created)])
    end

    def nearby_fires
        #turn into scope?
        Wildfire.current.select { |w| w.fire_within_radius(25, self.zip) }
    end
end
