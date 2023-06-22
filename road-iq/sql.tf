# Create the Cloud SQL instance
resource "google_sql_database_instance" "psql" {
  name            = var.db_instance_name
  database_version = "POSTGRES_11"
  region          = var.region

  settings {
    tier = var.db_instance_tier
  }
}
