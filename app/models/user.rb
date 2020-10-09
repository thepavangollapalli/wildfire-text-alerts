class User < ApplicationRecord
    has_many :wildfires, through: :wildfire_text_alerts

    validates :phone, format: { with: /(\+1)[0-9]{10}/, message: "must include US country code (+1)" }
    validates :zip, inclusion: { in: ZipToCoordsHelper::LOOKUP_HASH.keys, message: "is not a valid US zip code" }
    validates :phone, uniqueness: { scope: :zip, message: "can only be used once per zip"}

    after_create :send_current_fires

    def to_h
        h = Hash.new
        fires = self.nearby_fires
        one_fire = fires.count == 1
        zero_fires = fires.count == 0
        intro_msg = "There #{one_fire ? "is" : "are"} #{fires.count} #{one_fire ? "fire" : "fires"} near you#{zero_fires ? "." : ": "}"
        h[self.phone.to_s] = intro_msg + fires.join(" ")
        h
    end

    def send_current_fires
        SendTextWorker.perform_async(self.to_h)
    end

    def nearby_fires
        #turn into scope?
        Wildfire.select { |w| w.fire_within_radius(25, self.zip) }
    end
end
