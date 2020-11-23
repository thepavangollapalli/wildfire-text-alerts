require 'test_helper'
require 'sidekiq/testing'
include WebMock::API

class IrwinApiPollingWorkerTest < ActiveSupport::TestCase
    STUB_API_RESPONSE = {
        "features": [
            {
                "attributes": {
                    "OBJECTID": 123123,
                    "CalculatedAcres": 13,
                    "IncidentName": "F1",
                    "InitialLatitude": "38.886669",
                    "InitialLongitude": "-77.029444",
                    "FireDiscoveryDateTime": Time.now.to_s,
                    "POOFips": nil,
                    "ArchivedOn": nil,
                    "PercentContained": 80.0
                }
            },
            {
                "attributes": {
                    "CalculatedAcres": 21,
                    "IncidentName": "F2",
                    "InitialLatitude": "38.886669",
                    "InitialLongitude": "-77.029444",
                    "FireDiscoveryDateTime": Time.now.to_s,
                    "POOFips": nil,
                    "ArchivedOn": nil,
                    "PercentContained": nil
                }
            },
            {
                "attributes": {
                    "CalculatedAcres": 34,
                    "IncidentName": "F3",
                    "InitialLatitude": "38.886669",
                    "InitialLongitude": "-77.029444",
                    "FireDiscoveryDateTime": Time.now.to_s,
                    "POOFips": nil,
                    "ArchivedOn": nil,
                    "PercentContained": 0.0
                }
            }
        ]
    }

    setup do
        Sidekiq::Testing.inline!

        stub_request(:get, "https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Active_Fires/FeatureServer/0/query?f=json&outFields=*&outSR=4326&where=1=1")
        .to_return(body: STUB_API_RESPONSE.to_json, headers: {content_type: 'application/json'})
    end

    test "ignores nil values in response row when inserting" do
        IrwinApiPollingWorker.perform_async
        actual_percentage = Wildfire.find_by(incident_name: "F2").percent_contained
        assert_equal 0.0, actual_percentage, "Did not use default db value when saving fire"
    end

    test "creates new wildfire record when none exists" do
        assert_nil Wildfire.find_by(incident_name: "F1"), "Wildfire record exists when it shouldn't"
        IrwinApiPollingWorker.perform_async
        assert_not_nil Wildfire.find_by(incident_name: "F1"), "Wildfire record not created by worker"
    end

    test "updates existing wildfire record if present" do
        fire = Wildfire.find_by(object_id: 123123)
        assert_equal 12.3, fire.percent_contained, "Wildfire percent contained is a different value"
        IrwinApiPollingWorker.perform_async
        assert_equal 80.0, fire.reload.percent_contained, "Wildfire record not updated by worker"
    end

    test "marks db rows not in response as stale" do
        fire = Wildfire.find_by(incident_name: "FireThree")
        assert_not fire.stale, "Fire record is already stale"
        IrwinApiPollingWorker.perform_async
        assert fire.reload.stale, "Fire record is not marked stale"
    end
end