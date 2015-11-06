[![Build Status](https://travis-ci.org/gtranchedone/NFYU.svg)](https://travis-ci.org/gtranchedone/NFYU)

# NFYU

Never Forget Your Umbrella is a sample iPhone app that demonstrates
 how you can develop a fully formed iOS application using Test-Driven
 Development in Swift.

NFYU uses OpenWeatherMap APIs to fetch the forcast data but is
 extensible to any other service. To do that, you can create and use
 a new class comforming to the WeatherDataSource protocol.

## TODO

- [x] ~~Create setup screen for using user location~~
- [x] ~~Make main screen have a way to display settings
 for adding / remoing cities~~
- [x] ~~Add favourite cities input in setup screen~~
- [x] ~~Fetch weather data from OpenWeatherMap APIs~~
- [ ] Fill the UI with the forecast data
- [ ] Add support for C and F temperature units

-- After MVP --

- [ ] Expand UI and APIs usage as needed for 5 days forecast
- [ ] Cache weather data for offline use (last update date must be clear)
- [ ] Add API localization support
- [ ] Use Google Places API instand of CLGeocoder for more results?

