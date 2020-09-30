class Wildfire < ApplicationRecord
    has_many :users, through: :wildfire_text_alerts

    # after a wildfire is reported, which users are affected?
    # after_create hook to queue text for all users affected by fire

    # helper method to find all users within 25 miles of fire
    # prefer lat/long, fall back on fips

    # helper method to convert fips to lat/long
    def fips_to_coords(fips)
        FipsToCoordsHelper::LOOKUP[fips]
    end

    # helper method to convert zip to lat/long
    def zip_to_coords(zip)
        ZipToCoordsHelper::LOOKUP[zip]
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
