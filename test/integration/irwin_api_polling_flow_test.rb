require 'test_helper'
require 'sidekiq/testing'
require_relative '../workers/irwin_api_polling_worker_test.rb'

class IrwinApiPollingFlowTest < ActionDispatch::IntegrationTest
    IrwinApiPollingWorkerTest::STUB_API_RESPONSE[:features].push({
        "attributes": {
            "OBJECTID": 123987,
            "CalculatedAcres": 34,
            "IncidentName": "F4",
            "InitialLatitude": nil,
            "InitialLongitude": nil,
            "FireDiscoveryDateTime": Time.now.to_s,
            "POOFips": 23029,
            "ArchivedOn": nil,
            "PercentContained": 0.0
        }
    })
    STUB_API_RESPONSE = IrwinApiPollingWorkerTest::STUB_API_RESPONSE

    setup do
        Sidekiq::Testing.inline!

        stub_request(:get, "https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/Active_Fires/FeatureServer/0/query?f=json&outFields=*&outSR=4326&where=1=1")
        .to_return(body: STUB_API_RESPONSE.to_json, headers: {content_type: 'application/json'})
    end

    test "sends text to nearby users after updating fire records" do
        assert_nothing_raised do
            IrwinApiPollingWorker.perform_async
        end
    end
end