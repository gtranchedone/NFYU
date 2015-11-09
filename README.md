[![Build Status](https://travis-ci.org/gtranchedone/NFYU.svg)](https://travis-ci.org/gtranchedone/NFYU)

# NFYU

Never Forget Your Umbrella is a sample iPhone app that demonstrates
 how you can develop a fully formed iOS application using Test-Driven
 Development in Swift.

NFYU uses OpenWeatherMap APIs to fetch the forcast data but is
 extensible to any other service. To do that, you can create and use
 a new class comforming to the WeatherDataSource protocol.

## Project Setup

This project comes with a shared OpenWeatherMap API Key stored in the
Xcode's NFYU configuration as environment varialble. You can use this
API Key but it would be best if you changed it to your own.

## TODO

- [x] ~~Create setup screen for using user location~~
- [x] ~~Make main screen have a way to display settings
 for adding / remoing cities~~
- [x] ~~Allow user to sort favourite locations~~
- [x] ~~Add favourite cities input in setup screen~~
- [x] ~~Fetch weather data from OpenWeatherMap APIs~~
- [x] ~~Display current forecast data on screen~~
- [x] ~~Add support for C and F temperature units~~
- [x] ~~Add hourly forecast~~

-- After MVP --

- [ ] Improve UI and add 5 days forecast
- [ ] Cache weather data for offline use (last update date must be clear)
- [ ] Use Google Places API instand of CLGeocoder for more results?

