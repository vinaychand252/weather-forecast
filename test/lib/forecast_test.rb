require "test_helper"
require 'webmock/minitest'

class ForecastTest < ActiveSupport::TestCase
  setup do
    @forecast = Forecast.new("blah-key")
  end

  test "#call with zip code" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 200, body: { a: "b" }.to_json, headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 200, body: { c: "d" }.to_json, headers: {})
    
    assert_equal @forecast.call("94040"), { current: { a: "b" }, third_hourly: { c: "d" } }.as_json
  end

  test "#call with city" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 200, body: { a: "b" }.to_json, headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 200, body: { c: "d" }.to_json, headers: {})
    
    assert_equal @forecast.call("New York"), { current: { a: "b" }, third_hourly: { c: "d" } }.as_json
  end

  test "when there is a http error in first request" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 400, body: { a: "b" }.to_json, headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 200, body: { c: "d" }.to_json, headers: {})
    
    assert_nil @forecast.call("94040")
  end

  test "when there is a json error in first request" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          zip: '94040,us'
        }.as_json
      )
      .to_return(status: 200, body: { c: "d" }.to_json, headers: {})
    
    assert_nil @forecast.call("94040")
  end

  test "when there is a http error in second request" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 200, body: { a: "b" }.to_json, headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 400, body: { c: "d" }.to_json, headers: {})
    
    assert_nil @forecast.call("New York")
  end

  test "when there is a json error in second request" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 200, body: { a: "b" }.to_json, headers: {})

    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(
        query: {
          appid: 'blah-key',
          units: 'imperial',
          q: 'New York,us'
        }.as_json
      )
      .to_return(status: 200, body: "", headers: {})
    
    assert_nil @forecast.call("New York")
  end
end
