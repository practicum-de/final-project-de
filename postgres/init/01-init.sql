CREATE USER student WITH PASSWORD 'student';

CREATE USER airflow_user WITH PASSWORD 'airflow_pass';
CREATE DATABASE airflow_db OWNER airflow_user;
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;

CREATE DATABASE metabase OWNER admin;
