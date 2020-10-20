class Wildfire < ApplicationRecord
    scope :current, -> { where(stale: false) }

    after_create :alert_users_that_fire_started
    after_update :alert_users_that_fire_over

    def alert_users_that_fire_started
        SendTextWorker.perform_async(self.users_near_self.map{ |u| u.to_h(:fire_started, self) })
    end

    def alert_users_that_fire_over
        if self.is_contained? && (users_to_text = self.users_near_self).present?
            SendTextWorker.perform_async(users_to_text.map{ |u| u.to_h(:fire_ended, self) })
        end
    end

    def users_near_self
        User.all.select { |u| self.fire_within_radius(25, u.zip) }
    end

    def to_s
        "#{self.incident_name} (#{display_commas(self.calculated_acres)} acres, #{"%.0f" % self.percent_contained}% contained) reported at #{self.initial_latitude}, #{self.initial_longitude}."
    end

    # helper method to return if fire is within x miles of zip
    # Turn fire_within_radius into helper that returns distance

    def fire_within_radius(radius, zip)
        if self.initial_latitude && self.initial_longitude
            lat, long = self.initial_latitude, self.initial_longitude
        else
            lat, long = fips_to_coords(self.fips)
        end
        user_lat, user_long = zip_to_coords(zip)

        dist = distance_between_coords(lat, long, user_lat, user_long)
        dist < radius
    end

    def is_contained?
        self.percent_contained == 100.0 || self.archived_on.present? || self.stale
    end

    private

    # 145829.323 -> "145,829.32"
    def display_commas(number)
        number.round(2).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    # helper method to convert fips to lat/long
    def fips_to_coords(fips)
        FipsToCoordsHelper::LOOKUP_HASH[fips].map(&:to_f)
    end

    # helper method to convert zip to lat/long
    def zip_to_coords(zip)
        ZipToCoordsHelper::LOOKUP_HASH[zip].map(&:to_f)
    end

    # helper method to calculate distance between two lat/longs
    # uses haversine formula from https://www.movable-type.co.uk/scripts/latlong.html
    def distance_between_coords(lat0, long0, lat1, long1)
        # trig fn inputs need to be radians
        rad_lat0 = convert_to_radians(lat0)
        rad_lat1 = convert_to_radians(lat1)
        rad_lat_diff = convert_to_radians(lat1 - lat0)
        rad_long_diff = convert_to_radians(long1 - long0)

        a = Math.sin(rad_lat_diff / 2) ** 2 + Math.cos(rad_lat0) * Math.cos(rad_lat1) * (Math.sin(rad_long_diff / 2) ** 2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

        # Equatorial radius in miles
        earth_radius = 3963.1906
        earth_radius * c
    end

    def convert_to_radians(val)
        val * (Math::PI / 180)
    end
end
