require "test_helper"
require "mocha/minitest"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data = {
      current: { 
        name: "Mountain View",
        timezone: -28800,
        main: {
          temp: "53.92",
          feels_like: "52.86",
          temp_min: "51.84",
          temp_max: "56.68"
        },
        weather: [
          {
            main: "Clouds",
            description: "broken clouds"
          }
        ]
      },
      third_hourly: {
        list: [
          main: {
            temp: "47.93",
            feels_like: "46.51",
            temp_min: "47.93",
            temp_max: "47.93"
          },
          weather: [
            {
              main: "Clouds",
              description: "overcast clouds"
            }
          ],
          dt_txt: "2024-02-10 03:00:00"
        ]
      }
    }
  end

  teardown do
    Rails.cache.clear
  end

  test "routes" do
    assert_recognizes({ controller: 'forecasts', action: 'show' }, '/')
    assert_routing '/forecast', controller: 'forecasts', action: 'show'
  end

  test "show when there is no q" do
    get forecast_path
    assert_response :success
    
    assert_no_match "Time", response.body
    assert_no_match "Temperature (Fahrenheit)", response.body
  end

  test "show when there is q" do
    Rails.application.credentials.openweathermap.expects(:api_key).returns("blah-key")

    mock_forecast = mock("Forecast")
    mock_forecast.expects(:call).with("94040").returns(@data.as_json)
    Forecast.expects(:new).with("blah-key").returns(mock_forecast)

    get forecast_path, params: { q: "94040" }
    assert_response :success

    assert_match "Mountain View", response.body

    assert "Time", response.body
    assert "Temperature (Fahrenheit)", response.body

    assert_match "Current", response.body
    assert_match "53.92", response.body
    assert_match "52.86", response.body
    assert_match "51.84 / 56.68", response.body
    assert_match "Clouds / broken clouds", response.body

    assert_match "2024-02-09 19:00:00 -0800", response.body
    assert_match "47.93", response.body
    assert_match "46.51", response.body
    assert_match "47.93 / 47.93", response.body
    assert_match "Clouds / overcast clouds", response.body
  end

  test "show with cached result" do
    Rails.cache.expects(:read).with("forecast/94040").returns(@data.as_json)

    get forecast_path, params: { q: "94040" }
    assert_response :success

    assert_match "Result was pulled from the cache.", response.body
  end

  test "show when no results found" do
    Rails.application.credentials.openweathermap.expects(:api_key).returns("blah-key")

    mock_forecast = mock("Forecast")
    mock_forecast.expects(:call).with("94040").returns(nil)
    Forecast.expects(:new).with("blah-key").returns(mock_forecast)

    get forecast_path, params: { q: "94040" }
    assert_response :success

    assert_match "No results found", response.body
  end
end
