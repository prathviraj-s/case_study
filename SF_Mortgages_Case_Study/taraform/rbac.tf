# ============================================================
# ROLES
# ============================================================

resource "snowflake_account_role" "analyst_role" {
  name    = "MORTGAGE_ANALYST_ROLE"
  comment = "General analyst role with masked PII access"
}

resource "snowflake_account_role" "compliance_role" {
  name    = "MORTGAGE_COMPLIANCE_ROLE"
  comment = "Compliance officer role with unmasked PII access"
}


# ============================================================
# DATABASE ACCESS
# ============================================================

resource "snowflake_grant_privileges_to_account_role" "analyst_database" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.analyst_role.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.mortgage_db.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_database" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compliance_role.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.mortgage_db.name
  }
}


# ============================================================
# SILVER ACCESS
# ============================================================

resource "snowflake_grant_privileges_to_account_role" "analyst_silver" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.analyst_role.name

  on_schema {
    schema_name = "${snowflake_database.mortgage_db.name}.${snowflake_schema.silver.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_silver" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compliance_role.name

  on_schema {
    schema_name = "${snowflake_database.mortgage_db.name}.${snowflake_schema.silver.name}"
  }
}


# ============================================================
# GOLD ACCESS
# ============================================================

resource "snowflake_grant_privileges_to_account_role" "analyst_gold" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.analyst_role.name

  on_schema {
    schema_name = "${snowflake_database.mortgage_db.name}.${snowflake_schema.gold.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_gold" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compliance_role.name

  on_schema {
    schema_name = "${snowflake_database.mortgage_db.name}.${snowflake_schema.gold.name}"
  }
}