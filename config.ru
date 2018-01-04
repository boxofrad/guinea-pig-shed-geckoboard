require 'geckoboard'

GECKOBOARD_API_KEY = ENV.fetch('GECKOBOARD_API_KEY')
WEBHOOK_AUTH_TOKEN = ENV.fetch('WEBHOOK_AUTH_TOKEN')

dataset = Geckoboard.client(ENV.fetch('GECKOBOARD_API_KEY'))
  .datasets
  .find_or_create('guinea_pig_shed', fields: [
    Geckoboard::DateTimeField.new(:timestamp, name: 'Timestamp'),
    Geckoboard::NumberField.new(:mansion_temperature, name: 'Mansion Temperature'),
    Geckoboard::NumberField.new(:annex_temperature, name: 'Annex Temperature'),
  ], unique_by: [:timestamp])

run -> env do
  request = Rack::Request.new(env)

  case
  when env['X-Auth-Token'] != WEBHOOK_AUTH_TOKEN
    [401, {}, ['Unauthorized']]
  when request.post?
    payload = JSON.parse(request.body.read)
    data = JSON.parse(payload.fetch('data'))

    dataset.post([
      timestamp: payload.fetch('published_at'),
      mansion_temperature: data.fetch('mansion'),
      annex_temperature: data.fetch('annex'),
    ])

    [200, {}, ['OK']]
  else
    [200, {}, ['Hello World']]
  end
end
