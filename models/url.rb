# frozen_string_literal: true

# The Url class represents the data model for the URL shortener.
# It is responsible for the business logic, such as searching for and saving
# URLs in the SQLite database.
class Url
  attr_accessor :original_url, :shortener_code

  def initialize(original_url, shortener_code)
    @original_url = original_url
    @shortener_code = shortener_code
  end

  def self.find_by(code)
    row = Database.connection.get_first_row(
      'SELECT original_url FROM urls_shortened WHERE shortener_code = ?',
      [code]
    )
    row ? new(row['original_url'], code) : nil
  end

  def self.create(url, code)
    Database.connection.execute(
      'INSERT INTO urls_shortened (original_url, shortener_code) VALUES (?, ?)',
      [url, code]
    )
    new(url, code)
  rescue SQLite3::Exception => e
    warn "Erro no Model: #{e.message}"
    nil
  end
end
