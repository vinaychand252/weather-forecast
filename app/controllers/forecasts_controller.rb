class ForecastsController < ApplicationController
  after_action -> { flash.clear }

  def show
    q = search_params[:q]
    render and return unless q

    forecasts = fetch_forecast_info(q) do
      flash[:notice] = "Result was pulled from the cache."
    end
    if forecasts
      render locals: { forecasts:, q: }
    else
      flash[:alert] = "No results found"
    end
  end

  private

  def search_params
    params.permit(:q)
  end

  def fetch_forecast_info(q)
    cache_key = "forecast/#{q.parameterize.underscore}"
    if forecasts = Rails.cache.read(cache_key)
      yield
    else
      forecasts = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        api_key = Rails.application.credentials.openweathermap.api_key
        Forecast.new(api_key).call(q)
      end
    end
    forecasts
  end
end
