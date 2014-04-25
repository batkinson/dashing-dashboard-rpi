require 'net/http'
require 'openssl'
require 'json'

github_username = ENV['GITHUB_USERINFO_USERNAME'] || 'users/batkinson'

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.github.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/#{github_username}"))
  data = JSON.parse(response.body)

  if response.code != "200"
    puts "github api error (status-code: #{response.code})\n#{response.body}"
  else
    send_event('github_userinfo_followers', current: data['followers'])
    send_event('github_userinfo_following', current: data['following'])
    send_event('github_userinfo_repos', current: data['public_repos'])
    send_event('github_userinfo_gists', current: data['public_gists'])
  end
end


github_username = 'users/batkinson'

max_length = 7
ordered = true

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.github.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/#{github_username}/repos"))
  data = JSON.parse(response.body)

  if response.code != "200"
    puts "github api error (status-code: #{response.code})\n#{response.body}"
  else
    repos_forks = Array.new
    repos_watchers = Array.new
    data.each do |repo|
      repos_forks.push({
        label: repo['name'],
        value: repo['forks']
      })
      repos_watchers.push({
        label: repo['name'],
        value: repo['watchers']
      })
    end

    if ordered
      repos_forks = repos_forks.sort_by { |obj| -obj[:value] }
      repos_watchers = repos_watchers.sort_by { |obj| -obj[:value] }
    end

    send_event('github_user_repos_forks', { items: repos_forks.slice(0, max_length) })
    send_event('github_user_repos_watchers', { items: repos_watchers.slice(0, max_length) })

  end # if

end # SCHEDULER
