# Локальное окружение для финального проекта

В compose поднимаются:

- PostgreSQL 13 для учебной базы `de`, базы Airflow `airflow_db` и базы Metabase `metabase`.
- Airflow `2.4.1` с провайдерами `apache-airflow-providers-postgres` и `apache-airflow-providers-amazon`.
- PySpark `3.2.3` внутри Airflow-образа, чтобы запускать Spark-код прямо из DAG/job Airflow.
- Metabase `v0.41.5`.
- Greenplum `andruche/greenplum:7`.

## Запуск

Создайте локальные директории для Airflow и Spark:

```bash
mkdir -p dags logs plugins spark
```

На Linux дополнительно задайте пользователя для файлов Airflow:

```bash
echo "AIRFLOW_UID=$(id -u)" > .env
```

Соберите образ Airflow с нужными провайдерами/PySpark и запустите сервисы:

```bash
docker compose up -d --build
```

Проверить состояние контейнеров:

```bash
docker compose ps
```

Остановить окружение:

```bash
docker compose down
```

Остановить окружение и удалить данные PostgreSQL/Greenplum:

```bash
docker compose down -v
```

## Подключения

### PostgreSQL

С хоста:

```bash
psql postgresql://admin:BuMPLjDgRLjtmuarWBsd@localhost:5432/de
psql postgresql://student:student@localhost:5432/de
```

Из контейнеров Docker Compose используйте хост `postgres`:

```text
postgresql://admin:BuMPLjDgRLjtmuarWBsd@postgres:5432/de
postgresql://student:student@postgres:5432/de
```

Для Airflow база находится там же:

```text
postgresql://airflow_user:airflow_pass@postgres:5432/airflow_db
```

### Airflow

Веб-интерфейс: <http://localhost:8080>

Логин и пароль по умолчанию:

```text
airflow / airflow
```

DAG-файлы кладите в директорию `dags/`.

### PySpark в Airflow

PySpark установлен в Airflow-образе. В DAG можно использовать обычный импорт:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.master("local[*]").appName("airflow-pyspark-job").getOrCreate()
```

Python-скрипты для Spark можно класть в директорию `spark/`; внутри Airflow она доступна как `/opt/airflow/spark`.

Проверить интерактивный PySpark внутри Airflow-контейнера:

```bash
docker compose exec airflow-webserver pyspark
```

Запустить Spark-скрипт вручную из директории `spark/`:

```bash
docker compose exec airflow-webserver spark-submit /opt/airflow/spark/example.py
```

### Metabase

Веб-интерфейс: <http://localhost:8998>

Metabase хранит свои настройки в PostgreSQL:

```text
host: postgres
port: 5432
database: metabase
user: admin
password: BuMPLjDgRLjtmuarWBsd
```

Чтобы подключить в Metabase учебную PostgreSQL-базу `de`, укажите:

```text
host: postgres
port: 5432
database: de
user: student
password: student
```

### Greenplum

Greenplum доступен с хоста на порту `5433`, чтобы не конфликтовать с PostgreSQL:

```bash
psql -h localhost -p 5433 -U student -d de
```

Пароль пользователя `student`:

```text
/RF7s4G4YDk1/aBjOptSdkgAFl78m/fI
```

Из других контейнеров compose используйте хост `greenplum` и порт `5432`.
