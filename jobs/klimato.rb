require "net/http"
require "json"

# WOEID for location:
# http://woeid.rosselliot.co.nz
woeid = ENV['WEATHER_WOEID']

# Units for temperature:
# f: Fahrenheit
# c: Celsius
format = ENV['WEATHER_UNIT']

query  = URI::encode "select * from weather.forecast WHERE woeid=#{woeid} and u='#{format}'&format=json"

SCHEDULER.every "5m", :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]

  if results
    condition = results["channel"]["item"]["condition"]
    location  = results["channel"]["location"]
    send_event "klimato", { location: location["city"], temperature: condition["temp"], code: condition["code"], format: format }
  end
end
