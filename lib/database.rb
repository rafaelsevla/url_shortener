# frozen_string_literal: true

require 'sqlite3'

# Manages the connection and initial structure of the SQLite database.
class Database
  def self.connection
    db_name = ENV['APP_ENV'] == 'test' ? 'url_shortener_test.db' : 'url_shortener.db'

    @connection ||= SQLite3::Database.new(db_name).tap do |db|
      db.results_as_hash = true
    end
  end

  def self.setup
    connection.execute(create_table_sql)
  rescue SQLite3::Exception => e
    warn "Erro ao configurar banco: #{e.message}"
  end

  def self.create_table_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS shortened_urls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_url TEXT NOT NULL,
        shortener_code TEXT NOT NULL UNIQUE
      );
    SQL
  end
end
