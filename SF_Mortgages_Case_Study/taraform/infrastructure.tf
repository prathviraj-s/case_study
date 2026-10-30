# ============================================================
# DATABASE
# ============================================================

resource "snowflake_database" "my_db" {
  name    = var.database_name
  comment = "Mortgage application and underwriting database"
}


# ============================================================
# SCHEMAS
# ============================================================

resource "snowflake_schema" "standard" {
  database = snowflake_database.mortgage_db.name
  name     = "standard"
  comment = "Raw JSON and CSV landing layer"
}


resource "snowflake_schema" "silver" {
  database = snowflake_database.mortgage_db.name
  name     = "SILVER"
  comment = "Cleaned, joined and validated mortgage applications"
}


resource "snowflake_schema" "gold" {
  database = snowflake_database.mortgage_db.name
  name     = "GOLD"
  comment = "Mortgage underwriting decisions and HMDA reporting"
}


resource "snowflake_schema" "control" {
  database = snowflake_database.mortgage_db.name
  name     = "CONTROL"
  comment = "Airflow checkpoint and operational metadata"
}


resource "snowflake_schema" "security" {
  database = snowflake_database.mortgage_db.name
  name     = "SECURITY"
  comment = "PII masking policies and security objects"
}


# ============================================================
# TRANSFORMATION WAREHOUSE
# ============================================================

resource "snowflake_warehouse" "transform_wh" {
  name = var.warehouse_name
  warehouse_size = var.warehouse_size
  auto_suspend = 60
  auto_resume  = true
  initially_suspended = true
  comment = "Warehouse for mortgage dbt transformations"
}