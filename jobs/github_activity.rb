require 'net/http'
require 'openssl'
require 'json'
require 'time'

github_username = ENV['GITHUB_USERINFO_USERNAME']

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("github.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/#{github_username}/contributions_calendar_data"))
  data = JSON.parse(response.body)

  if response.code != "200"
    puts "github api error (status-code: #{response.code})\n#{response.body}"
  else
   data = data.last(30).collect { |point| { x: Time.strptime(point[0],'%Y/%m/%d').tv_sec(), y: point[1] } }
   send_event('github_activity', points: data)
  end
end
