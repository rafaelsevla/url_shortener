# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'rspec'
require 'rack/test'
require 'json'
require 'fileutils'

RSpec.describe 'URL Shortener API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    Database.setup
  end

  before(:each) do
    Database.connection.execute('DELETE FROM shortened_urls')
  end

  after(:all) do
    Database.connection.close
    FileUtils.rm_f('url_shortener_test.db')
  end

  describe 'POST /api/short' do
    context 'when providing a valid URL' do
      it 'shortens the URL successfully' do
        payload = { url: 'https://google.com' }.to_json
        header 'Content-Type', 'application/json'
        post '/api/short', payload

        expect(last_response.status).to eq(200)

        response_data = JSON.parse(last_response.body)
        expect(response_data['message']).to eq('Url encurtada com sucesso')
        expect(response_data['new_url']).to match(/^[A-Z]{8}$/)
      end
    end

    context 'when providing an empty URL' do
      it 'returns a 400 Bad Request error' do
        payload = { url: '' }.to_json
        header 'Content-Type', 'application/json'
        post '/api/short', payload

        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)['error']).to eq('Url inválida')
      end
    end
  end

  describe 'GET /api/shorted/:code' do
    context 'when the code exists' do
      it 'redirects to the original URL' do
        code = 'ABCDEFGH'
        Url.create('https://github.com', code)

        get "/api/shorted/#{code}"

        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq('https://github.com')
      end
    end

    context 'when the code does not exist' do
      it 'returns a 404 Not Found error' do
        get '/api/shorted/NOTFOUND'

        expect(last_response.status).to eq(404)
        expect(last_response.body).to include('Página não encontrada')
      end
    end
  end
end
