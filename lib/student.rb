

class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    # self.new is the same as running Student.new
    new_student = self.new
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    # return the newly created instance
    new_student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    sql = <<-SQL
      SELECT * FROM students
    SQL
    # DB[:conn].execute(sql) returns an array of rows from the database that match the query
    # => [[1, "Pat", "12"], [2, "Sam", "10"]]
    # but, need to iterate over rows to create a new instance of the Student class for each
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students WHERE name=?;
    SQL
    student = DB[:conn].execute(sql, name).flatten
    Student.new_from_db(student)
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
      SELECT * FROM students WHERE grade=9
    SQL
    DB[:conn].execute(sql).collect do |student|
      student[1]
    end
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT * FROM students WHERE grade < 12
    SQL
    DB[:conn].execute(sql).collect do |student|
      student[1]
    end
  end

  def self.first_x_students_in_grade_10(number)
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 10 LIMIT ?
    SQL
    DB[:conn].execute(sql,number).collect do |grade_10_student|
      self.new_from_db(grade_10_student)
    end
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 10 LIMIT 1
    SQL
    student = DB[:conn].execute(sql).flatten
    self.new_from_db(student)
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
      SELECT * FROM students WHERE grade=?
    SQL
    DB[:conn].execute(sql, grade).collect do |student|
      student[1]
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
