from os import getenv

from dotenv import load_dotenv
from pyspark.sql import SparkSession
from pyspark.sql.dataframe import DataFrame


load_dotenv()

DB_HOST     = getenv("DB_HOST") or ""
DB_USER     = getenv("DB_USER") or ""
DB_PASSWORD = getenv("DB_PASSWORD") or ""
DB_NAME     = getenv("DB_NAME") or ""
POSTGRES_DRIVER_PATH = getenv("POSTGRES_DRIVER_PATH") or ""

DB_URL = f"jdbc:postgresql://{DB_HOST}:5432/{DB_NAME}"

properties = {
    "user": DB_USER,
    "password": DB_PASSWORD,
    "driver": "org.postgresql.Driver"
}

spark = SparkSession.Builder() \
            .appName("StarComex") \
            .config("spark.driver.extraClassPath", POSTGRES_DRIVER_PATH) \
            .getOrCreate()


def get_paises() -> DataFrame:
    query = "(select * from public.paises) paises"
    result = spark.read.jdbc(DB_URL, table=query, properties=properties)
    return result


paises = get_paises()

paises.show()
