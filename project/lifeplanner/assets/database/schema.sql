CREATE TABLE system_info (
  id INTEGER PRIMARY KEY CHECK (id = 0),
  last_enter TEXT
);

-- ACTIVITY ---------------------------------------------

CREATE TABLE courses (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  finished INTEGER,
  dedication_study_time_x_week INTEGER,
  actual_study_time_x_week INTEGER,
  total_dedication_time INTEGER
);

CREATE TABLE events (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  timeslot_start_date TEXT,
  timeslot_end_date TEXT,
  state TEXT,
  category_id INTEGER, -- reference event_categories table
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
);

CREATE TABLE event_categories (
  id INTEGER PRIMARY KEY,
  category TEXT UNIQUE 
);

CREATE TABLE sports (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  dedication_time_x_week INTEGER,
  actual_dedication_time_x_week INTEGER,
  total_dedicated_time INTEGER,
  schedule TEXT -- entire timetable as a JSON-encoded string
);


CREATE TABLE subjects (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  schedule TEXT,  -- entire timetable as a JSON-encoded string
  dedication_time_x_week INTEGER,
  actual_dedication_time_x_week INTEGER, 
  total_dedication_time INTEGER,
  target_average REAL,
  room INTEGER,
  grades TEXT,  -- entire Grades as a JSON-encoded string
  evaluations TEXT -- entire Evaluation list as a JSON-encoded string
);

-- FINANCE --------------------------------------------
CREATE TABLE balance (
  id INTEGER PRIMARY KEY CHECK (id = 0),
  current_available REAL,
  expected_remaining REAL
);

CREATE TABLE budgets (
  id INTEGER PRIMARY KEY,
  month TEXT,
  total_expense_expected REAL,
  total_income_expected REAL,
  budget_expenses TEXT, -- entire budget_expenses as a JSON-encoded string
  budget_incomes TEXT --entire budget_incomes as a JSON-encoded string
);

CREATE TABLE budget_categories (
  id INTEGER PRIMARY KEY,
  category TEXT UNIQUE 
);

CREATE TABLE expenses (
  id INTEGER PRIMARY KEY,
  date TEXT,
  amount REAL,
  concept TEXT,
  budget_or_not INTEGER,
  category_id INTEGER, -- reference budget_categories table
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
);

CREATE TABLE incomes (
  id INTEGER PRIMARY KEY,
  date TEXT,
  amount REAL,
  concept TEXT,
  budget_or_not INTEGER,
  category_id INTEGER, -- reference budget_categories table
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
);

CREATE TABLE savings (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  target_amount REAL,
  current_saved REAL,
  contributions --entire contributions as a JSON-encoded string
);

----JOB----------------
CREATE TABLE jobs (
  id INTEGER PRIMARY KEY,
  schedule TEXT, -- Storing as a JSON-encoded string
  type TEXT,
  name TEXT,
  total_hours INTEGER,
  income_id INTEGER,
  FOREIGN KEY (income_id) REFERENCES incomes(id)
);

CREATE TABLE vacations (
  id INTEGER PRIMARY KEY,
  start_date TEXT,
  end_date TEXT,
  days INTEGER,
  title TEXT,
  type TEXT,
  job_id INTEGER, -- vacations can have a related job (not included in the class instance)
  FOREIGN KEY (job_id) REFERENCES jobs(id)
);

--ORGANIZATION-------------------------
CREATE TABLE goals (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  target_date TEXT,
  type TEXT,
  actual_date_achievement TEXT,
  achieved INTEGER
);

CREATE TABLE habit_trackers (
  id INTEGER PRIMARY KEY,
  month TEXT,
  year INTEGER,
  habits TEXT  -- habits as JSON encoded string
);

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  state TEXT,
  deadline TEXT,
  description TEXT,
  date_of_doing TEXT,
  timeslot_start_date TEXT,
  timeslot_end_date TEXT
);
