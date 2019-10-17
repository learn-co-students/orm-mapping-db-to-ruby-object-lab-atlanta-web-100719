class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.all
    sql = <<-SQL
    SELECT *
    FROM students
    SQL
    self.db_sql_rows(sql)
  end

  def self.all_students_in_grade_X(x)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = ?
    SQL
    self.db_sql_rows_param(sql, x)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    self.db_sql_rows_param(sql, name).first
  end

  def self.all_students_in_grade_9
    self.all_students_in_grade_X(9)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade < 12
    SQL

    self.db_sql_rows(sql)
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      LIMIT ?
    SQL

    self.db_sql_rows_param(sql, x)
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1).first
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

  private

  # a couple of helpers to keep it DRY

  def self.db_sql_rows(sql)
    DB[:conn].execute(sql).map { |row| self.new_from_db(row) }
  end

  def self.db_sql_rows_param(sql, x)
    DB[:conn].execute(sql, x).map { |row| self.new_from_db(row) }
  end
end
