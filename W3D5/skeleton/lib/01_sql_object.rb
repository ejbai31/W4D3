require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT *
      FROM #{self.table_name}
      LIMIT 0
    SQL
    cols.map!(&:to_sym)
    @columns = cols
  end

  def self.finalize!
    self.columns.each do |name|
      define_method(name) do
        self.attributes[name]
      end
      define_method( "#{name}=" ) do |value|
        self.attributes[name] = value
      end

    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT *
    FROM
      #{self.table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map{|result| self.new(result)}
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT #{table_name}.*
      FROM #{table_name}
      WHERE #{table_name}.id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |key, value|
      symbd = key.to_sym
      if self.class.columns.include?(symbd)
        self.send("#{symbd}=", value)
      else
        raise "unknown attribute '#{symbd}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map{|val| self.send(val)}
  end

  def insert
    col_names = @columns.join(",")
    question_marks = ["?"] * col_names.count
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
