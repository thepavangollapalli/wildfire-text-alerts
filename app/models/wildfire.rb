class Wildfire < ApplicationRecord
    has_many :users, through: :wildfire_text_alerts

    # after a wildfire is added, send to all users that are nearby
    # after_create hook to queue text for all users affected by fire


    # after a wildfire has stopped, send to all users that are nearby

    def to_s
        "#{self.incident_name} (#{self.calculated_acres} acres) reported\ at #{self.initial_latitude} #{self.initial_longitude}."
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

        dist = Wildfire.distance_between_coords(lat, long, user_lat, user_long)
        dist < radius
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
    def Wildfire.distance_between_coords(lat0, long0, lat1, long1)
        # Equatorial radius in miles
        earth_radius = 3963.1906

        # trig fn inputs need to be radians
        rad_lat0 = Wildfire.convert_to_radians(lat0)
        rad_lat1 = Wildfire.convert_to_radians(lat1)
        rad_lat_diff = Wildfire.convert_to_radians(lat1 - lat0)
        rad_long_diff = Wildfire.convert_to_radians(long1 - long0)

        a = Math.sin(rad_lat_diff / 2) ** 2 + Math.cos(rad_lat0) * Math.cos(rad_lat1) * (Math.sin(rad_long_diff / 2) ** 2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        earth_radius * c
    end

    def Wildfire.convert_to_radians(val)
        val * (Math::PI / 180)
    end
end
