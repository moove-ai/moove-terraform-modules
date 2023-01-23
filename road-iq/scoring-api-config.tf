data "google_secret_manager_secret_version" "clickhouse-user" {
  project = var.project_id
  secret  = "clickhouse_user"
}

data "google_secret_manager_secret_version" "clickhouse-password" {
  project = var.project_id
  secret  = "clickhouse_password"
}

data "google_secret_manager_secret_version" "postgres-postgres" {
  project = var.project_id
  secret  = "postgres_postgres"
}

data "google_secret_manager_secret_version" "postgres-bookmarks" {
  project = var.project_id
  secret  = "postgres_bookmarks"
}

resource "google_secret_manager_secret" "scoring-api-config" {
  project   = var.project_id
  secret_id = "scoring-api-config"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "scoring-api-config" {
  secret      = google_secret_manager_secret.scoring-api-config.id
  secret_data = local.clickhouse_secret
}

locals {
  clickhouse_secret = jsonencode({
    "postgres" : {
      "scoring-api" : "postgresql://postgres:${data.google_secret_manager_secret_version.postgres-postgres.secret_data}@${var.postgres_address}/scoring_api",
      "bookmarks-api" : "postgresql://bookmarks:${data.google_secret_manager_secret_version.postgres-bookmarks.secret_data}@${var.postgres_address}/bookmarks"
    },
    "bigquery" : {
      "platform-project" : "moove-platform-${var.environment}",
      "road-iq-project" : "moove-road-iq-${var.environment}"
    },
    "clickhouse" : {
      "host" : var.clickhouse_host,
      "user" : data.google_secret_manager_secret_version.clickhouse-user.secret_data,
      "password" : data.google_secret_manager_secret_version.clickhouse-password.secret_data,
    },
    "weather" : {
      "api-url" : "https://maps{int_1_to_4}.aerisapi.com/xwKI6BiyhDt9FG4uR3nNV_CP5lIlyxdOLdTN1Nvx9DGLbd3FAdzIfKrmOQN0so/radar/{zoom}/{tile_x}/{tile_y}/{time}.png",
      "cache" : {
        "bucket" : "weather-image-cache-road-iq-stage",
        "bucket-path" : "{z}/{x}/{y}/{time}{ext}",
        "job" : {
          "threads" : 32
        }
      }
    },
    "tile_cache" : {
      "bucket" : "tile-image-cache-road-iq-${var.environment}"
    },
    "auth" : {
      "auth0_domain" : var.auth0_domain,
      "auth0_algorithms" : ["RS256"],
      "auth0_audience" : var.auth0_audience,
      "token_domain" : var.auth0_token_domain
    },
    "flasgger" : {
      "version" : "0.4.0",
      "title" : "Scoring API",
      "description" : "",
      "headers" : [],
      "openapi" : "3.0.2",
      "specs" : [
        {
          "endpoint" : "apispec_1",
          "route" : "/flasgger/specs/apispec_1.json"
        }
      ],
      "static_url_path" : "/flasgger/static",
      "swagger_ui" : true,
      "specs_route" : "/apidocs/",
      "basePath" : "/api"
    }
  })
}
