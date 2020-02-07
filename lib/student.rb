require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        grade INTEGER
      );
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = <<-SQL
      DROP TABLE IF EXISTS students
      SQL
    
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
    
      sql = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?,?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(student)
    Student.new(student[1], student[2], student[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM students WHERE name = ?
      SQL

    return_value = DB[:conn].execute(sql, name)
    student = Student.new_from_db(return_value[0])
  end
end
