\c students

CREATE TABLE IF NOT EXISTS students (
    id      INTEGER PRIMARY KEY,
    name    TEXT NOT NULL,
    grade   INTEGER,
    email   TEXT
);

COPY students (id, name, grade, email)
FROM '/data/students.csv'
WITH (FORMAT csv, HEADER true);