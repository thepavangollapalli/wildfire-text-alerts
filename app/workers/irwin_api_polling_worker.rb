class IrwinApiPollingWorker
    include Sidekiq::Worker

    require "httparty"

    def perform
        # Add column for when a fire is no longer active
        api_to_db_cols = {
            "OBJECTID": "object_id", 
            "CalculatedAcres": "calculated_acres",
            "IncidentName": "incident_name",
            "InitialLatitude": "initial_latitude",
            "InitialLongitude": "initial_longitude",
            "FireDiscoveryDateTime": "discovered_at",
            "POOFips": "fips",
            "ArchivedOn": "archived_on",
            "PercentContained": "percent_contained"
        }.with_indifferent_access

        response = HTTParty.get("https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Active_Fires/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")
        if response.code != 200
            raise "API response is broken"
        end

        response_json = JSON.parse(response)
        fires = response_json["features"]
        seen_fire_ids = []
        fires.each do |f|
            fire = f["attributes"]
            attr_hash = { stale: false }
            api_to_db_cols.keys.each do |api_col|
                db_col = api_to_db_cols[api_col]
                val = fire[api_col]
                attr_hash[db_col] = val.respond_to?(:strip) ? val.strip : val
            end
            attr_hash.compact!
            fire_id = attr_hash["object_id"]
            wildfire = Wildfire.find_by(object_id: fire_id) || Wildfire.new
            wildfire.update(attr_hash)
            seen_fire_ids.push(fire_id)
            puts "Created record for #{wildfire.incident_name}"
        end
        puts "Created #{fires.length} rows from response. #{Wildfire.count} fires in total"
        # mark fires missing from response as stale
        stale_wildfires = Wildfire.where.not(object_id: seen_fire_ids)
        stale_wildfires.each{ |sw| sw.update({stale: true}) }
        puts "Marked #{stale_wildfires.count} fires as stale"
    end
end