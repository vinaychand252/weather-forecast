# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

3.3.0

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

bin/rails test

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


* Build and start instructions

1) Download my master.key and place it in `config/master.key`

2) This uses Docker and so need to run docker build and run:
`$ docker build -t weatherforecast:latest .`
`$ docker run -p 3001:3001 weatherforeceast:latest`

3) Launch https://localhost:3001

* Architecture

API Route (in config/routes.rb):
```
                         forecast GET  /forecast(.:format)                    forecasts#show
                             root GET  /                                      forecasts#show
```

Decomposition of objects:

ForecastsController (in app/controllers/forecasts_controller.rb) 
-> Forecast (in lib/forecast.rb)
-> show view template (in app/views/forecasts/show.html/erb)
   -> search partial view template (in app/views/forecasts/_search.html.erb)

* ...
