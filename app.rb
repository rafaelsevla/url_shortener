# frozen_string_literal: true

require_relative 'lib/database'
require_relative 'models/url'
require 'sinatra'

Database.setup

get '/api/shorted/:code' do
  result = Url.find_by(params['code'])
  if result
    redirect result.original_url
  else
    halt 404, 'Página não encontrada ou link expirado.'
  end
end

post '/api/short' do
  request.body.rewind
  data = JSON.parse(request.body.read)
  data_url = data['url']

  halt 400, { error: 'Url inválida' }.to_json if data_url.nil? || data_url.empty?

  code = random_string
  success = Url.create(data_url, code)

  halt 422, { error: 'Esta URL já foi encurtada ou o código falhou' }.to_json unless success

  {
    message: 'Url encurtada com sucesso',
    new_url: code
  }.to_json
end

def random_string
  (0...8).map { rand(65..90).chr }.join
end
