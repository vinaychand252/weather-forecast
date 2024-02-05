require "faraday"

class Forecast
  PRODUCT_TO_DATA_KEY = {
    weather: "current",
    forecast: "third_hourly"
  }

  def initialize(api_key)
    @conn = Faraday.new(url: 'https://api.openweathermap.org', 
                        params: { appid: api_key, units: 'imperial' }) do |builder|
      builder.response :raise_error
    end
  end

  def call(query)
    PRODUCT_TO_DATA_KEY.reduce({}) do |acc, (k, v)|
      response = by_zip_or_location(query, product: k)
      json = response ? JSON.parse(response.body) : nil
      return nil unless json
      acc[v] = json
      acc
    end
  rescue JSON::ParserError
    nil
  end

  private

  def by_zip_or_location(query, product:)
    if query =~ /\A\d+\z/
      by_zip(query, product:)
    else
      by_location(query, product:)
    end
  rescue Faraday::Error
    nil
  end

  def by_zip(zip_code, product:)
    @conn.get("/data/2.5/#{product}") do |req|
      req.params['zip'] = "#{zip_code},us"
    end
  end

  def by_location(loc, product:)
    @conn.get("/data/2.5/#{product}") do |req|
      req.params['q'] = "#{loc},us"
    end
  end
end
