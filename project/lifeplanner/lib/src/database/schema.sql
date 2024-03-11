-- schema.sql

---ACTIVITY---------------------------------------------
CREATE TABLE week_activity (
  id INTEGER PRIMARY KEY,
  week TEXT,
  dedication_study_time_x_week INTEGER,
  actual_study_time_x_week INTEGER,
  target_duration INTEGER
);

CREATE TABLE courses (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  finished INTEGER,
  target_duration INTEGER,
  week_activity_id INTEGER, -- foreign key to reference week_activity
  FOREIGN KEY (week_activity_id) REFERENCES week_activity(id) -- defining foreign key constraint
);

CREATE TABLE events (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  date_time TEXT,
  state TEXT,
  category_id INTEGER, -- Foreign key reference to event_categories table
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
);

CREATE TABLE event_categories (
  id INTEGER PRIMARY KEY,
  category TEXT UNIQUE -- Adding unique constraint
);

CREATE TABLE assessments (
  id INTEGER PRIMARY KEY,
  name TEXT,
  weight INTEGER
);

CREATE TABLE grades (
  id INTEGER PRIMARY KEY,
  assessment_id INTEGER,
  name TEXT,
  weight INTEGER,
  grade REAL,
  FOREIGN KEY (assessment_id) REFERENCES assessments(id)
);

CREATE TABLE languages (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  finished INTEGER,
  target_duration INTEGER,
  level TEXT,
  week_activity_id INTEGER, -- foreign key to reference week_activity
  FOREIGN KEY (week_activity_id) REFERENCES week_activity(id) -- defining foreign key constraint
);

CREATE TABLE sports (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  schedule TEXT
);

CREATE TABLE subjects (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  schedule_start_date TEXT, -- Weekly
  schedule_end_date TEXT, -- Weekly
  schedule_frequency INTEGER, -- Weekly : fixed?
  schedule_weekdays TEXT, -- Weekly
  target_average REAL,
  room INTEGER,
  week_activity_id INTEGER, -- foreign key to reference week_activity
  FOREIGN KEY (week_activity_id) REFERENCES week_activity(id) -- defining foreign key constraint
);

-- FINANCE --------------------------------------------
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY,
  month TEXT,
  total_expense_expected REAL,
  total_income_expected REAL,
  budget_category TEXT
);

CREATE TABLE budget_expenses (
  budget_id INTEGER PRIMARY KEY,
  category TEXT,
  amount REAL,
  FOREIGN KEY (budget_id) REFERENCES budgets(id)
);

CREATE TABLE budget_incomes (
  budget_id INTEGER PRIMARY KEY,
  category TEXT,
  amount REAL,
  FOREIGN KEY (budget_id) REFERENCES budgets(id)
);

CREATE TABLE expenses (
  id INTEGER PRIMARY KEY,
  date TEXT,
  amount REAL,
  concept TEXT,
  budget_or_not INTEGER,
  budget_category TEXT
);

CREATE TABLE incomes (
  id INTEGER PRIMARY KEY,
  date TEXT,
  amount REAL,
  concept TEXT,
  budget_or_not INTEGER,
  budget_category TEXT
);

CREATE TABLE budget_categories (
  id INTEGER PRIMARY KEY,
  name TEXT
);


CREATE TABLE savings (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  target_amount REAL,
  current_saved REAL
);

CREATE TABLE saving_contributions (
  saving_id INTEGER,
  date TEXT,
  amount REAL,
  FOREIGN KEY (saving_id) REFERENCES savings(id)
);


----JOB----------------
CREATE TABLE jobs (
  id INTEGER PRIMARY KEY,
  schedule_frequency INTEGER, -- Weekly : ver si hace falta a lo mejor para jobs puede ir fixed
  schedule_weekdays TEXT, -- Weekly
  schedule_start_date TEXT, --  Weekly 
  schedule_end_date TEXT, -- Weekly
  type TEXT,
  hours INTEGER,
  income_id INTEGER,
  FOREIGN KEY (income_id) REFERENCES incomes(id)
);


CREATE TABLE vacations (
  id INTEGER PRIMARY KEY,
  job_id INTEGER,
  schedule_start_date TEXT,
  schedule_end_date TEXT,
  days INTEGER,
  title TEXT,
  type TEXT,
  FOREIGN KEY (job_id) REFERENCES jobs(id)
);

--ORGANIZATION-------------------------

CREATE TABLE goals (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  target_date TEXT, -- Storing target date as text
  type TEXT,
  actual_date_achievement TEXT,
  achieved INTEGER
);

CREATE TABLE habit_trackers (
  id INTEGER PRIMARY KEY,
  month TEXT
);

CREATE TABLE habits (
  id INTEGER PRIMARY KEY,
  habit_tracker_id INTEGER,
  name TEXT,
  description TEXT,
  related_activity_id INTEGER,
  FOREIGN KEY (habit_tracker_id) REFERENCES habit_trackers(id),
  FOREIGN KEY (related_activity_id) REFERENCES activities(id)
);

CREATE TABLE habit_trackers (
  id INTEGER PRIMARY KEY,
  month TEXT
);

CREATE TABLE habits (
  id INTEGER PRIMARY KEY,
  habit_tracker_id INTEGER,
  name TEXT,
  description TEXT,
  related_activity_id INTEGER,
  FOREIGN KEY (habit_tracker_id) REFERENCES habit_trackers(id),
  FOREIGN KEY (related_activity_id) REFERENCES activities(id)
);

CREATE TABLE completed_dates (
  id INTEGER PRIMARY KEY,
  habit_id INTEGER,
  date TEXT,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);

CREATE TABLE projects (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  expected_start_date TEXT,
  expected_end_date TEXT,
  state TEXT,
  percentage_complete REAL
);

CREATE TABLE sprints (
  id INTEGER PRIMARY KEY,
  project_id INTEGER,
  sprint_start_date TEXT,
  sprint_end_date TEXT,
  project_start_date TEXT,
  project_end_date TEXT,
  total_hours_dedicated INTEGER,
  percentage_of_total_project_time REAL,
  name TEXT,
  description TEXT,
  done INTEGER
  FOREIGN KEY (project_id) REFERENCES projects(id)
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