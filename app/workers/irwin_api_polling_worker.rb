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
            "POOFips": "fips"
        }.with_indifferent_access

        response = HTTParty.get("https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Active_Fires/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")
        return unless response.code == 200
        
        response_json = JSON.parse(response)
        fires = response_json["features"]
        fires.each do |f|
            fire = f["attributes"]
            attr_hash = {}
            api_to_db_cols.keys.each do |api_col|
                db_col = api_to_db_cols[api_col]
                val = fire[api_col]
                attr_hash[db_col] = val.respond_to?(:strip) ? val.strip : val
            end
            fire_id = attr_hash["object_id"]
            wildfire = Wildfire.find_by(object_id: fire_id) || Wildfire.new
            wildfire.update(attr_hash)
            puts "Created record for #{wildfire.incident_name}"
        end
        puts "Created #{Wildfire.count} records from #{fires.length} api rows"
    end
end