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

        response = HTTParty.get("https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Active_Fires/FeatureServer/0/query?f=json&outFields=*&outSR=4326&where=1=1")
        if response.code != 200
            raise "API response is broken"
        end

        response_json = JSON.parse(response.body)
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
            irwin_lookup_id = attr_hash["object_id"]
            # Don't lookup nil object id in the db because then we'll modify another record with object id nil
            wildfire = irwin_lookup_id.present? ?  Wildfire.find_or_create_by(object_id: irwin_lookup_id) : Wildfire.new
            wildfire.update(attr_hash)
            seen_fire_ids.push(wildfire.id)
            puts "Created record for #{wildfire.incident_name}"
        end
        puts "Created #{fires.length} rows from response. #{Wildfire.count} fires in total"
        # mark fires missing from response as stale
        stale_wildfires = Wildfire.where.not(id: seen_fire_ids)
        stale_wildfires.each{ |sw| sw.update({stale: true}) }
        puts "Marked #{stale_wildfires.count} fires as stale"
    end
end