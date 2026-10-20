\c employees

CREATE TABLE IF NOT EXISTS staff (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    department  TEXT,
    salary      NUMERIC(10,2),
    hire_date   DATE
);

COPY staff (id, name, department, salary, hire_date)
FROM '/data/employees.csv'
WITH (FORMAT csv, HEADER true);