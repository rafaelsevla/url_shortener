# frozen_string_literal: true

require 'sqlite3'

# Manages the connection and initial structure of the SQLite database.
class Database
  def self.connection
    @connection ||= SQLite3::Database.new('url_shortener.db').tap do |db|
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
      CREATE TABLE IF NOT EXISTS urls_shortened (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_url TEXT NOT NULL,
        shortener_code TEXT NOT NULL UNIQUE
      );
    SQL
  end

  def self.create(original_url, shortener_code)
    connection.execute(
      'INSERT INTO urls_shortened (original_url, shortener_code) VALUES (?, ?)',
      [original_url, shortener_code]
    )
    true
  rescue SQLite3::ConstraintException => e
    puts "Erro: URL ou Código já existem no banco! #{e.message}"
    false
  rescue SQLite3::Exception => e
    puts "Erro ao inserir: #{e.message}"
    false
  end

  def self.find_url_by_code(shortener_code)
    result = connection.get_first_row(
      'SELECT original_url FROM urls_shortened WHERE shortener_code = ?',
      [shortener_code]
    )
    result['original_url']
  rescue SQLite3::Exception => e
    warn "Erro ao buscar: #{e.message}"
    nil
  end
end
