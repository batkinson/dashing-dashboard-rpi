#!/usr/bin/env ruby

require 'json'
require 'net/https'
require 'time'


num_tasks = 10

def api_call(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  header = {
    "Content-Type" => 'application/json'
  }

  req = Net::HTTP::Get.new(uri.request_uri, header)
  req.basic_auth(ENV['ASANA_CREDENTIALS'],nil)
  res = http.start { |http| http.request(req) }
  body = JSON.parse(res.body)

  return body['data']
end

def get_workspace
  workspaces = api_call('https://app.asana.com/api/1.0/workspaces')
  workspaces.each do |workspace|
    if workspace['name'] == 'General'
      return workspace
    end
  end
end

def get_workspace_tasks(workspace)
  beginning_of_day = Time.new(Time.now.year,Time.now.month,Time.now.mday).iso8601
  return api_call("https://app.asana.com/api/1.0/tasks?workspace=#{workspace['id']}&assignee=me&completed_since=#{beginning_of_day}")
end

def get_task_detail(task)
  return api_call("https://app.asana.com/api/1.0/tasks/#{task['id']}")
end

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

  list = Array.new
  tasks = get_workspace_tasks(get_workspace())
  i = 0
  
  tasks.each do |task|
    task_detail = get_task_detail(task)
    if task_detail['assignee_status'] == 'today'
      if task_detail['completed'] == true
        icon = 'icon-check'
      else
        icon = 'icon-check-empty'
      end
      list.push({label: task['name'], icon: icon})
      i += 1
    end
    break if i == num_tasks
  end

  send_event('asana_tasks', {items: list})

end
