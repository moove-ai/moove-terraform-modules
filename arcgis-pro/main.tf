locals {
  image = "${var.image_family}/${var.image_name}"
}

resource "google_compute_instance" "instance" {
  project      = var.project_id
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = local.image
      size  = var.disk_size
    }
  }

  network_interface {
    network    = "projects/${var.network_project_id}/global/networks/${var.environment}-vpc"
    subnetwork = "projects/${var.network_project_id}/regions/${var.region}/subnetworks/${var.environment}-${var.region}-subnetwork-private"
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
  tags = ["private", "rdp", "arcgis-pro"]

  metadata = {
    windows-startup-script-ps1 = <<-EOT
        $logFile = "C:\startup-log.txt"
        Add-Content -Path $logFile -Value "i hope this works" -Encoding UTF8

        # Enable RDP and configure Windows Firewall
        Set-NetFirewallRule -Name 'RemoteDesktop-UserMode-In-TCP' -Enabled True
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

        # Create new users
        ${join("\n", [for user in var.user_list : <<-SCRIPT
        $passwordSecret = gcloud secrets versions access "latest" --secret="${google_secret_manager_secret.user_passwords[user].secret_id}" --project "${google_secret_manager_secret.user_passwords[user].project}"
        $password${user} = ConvertTo-SecureString $passwordSecret -AsPlainText -Force
        "$password${user}" >> $logFile
        if (-not (Get-LocalUser -Name "${user}" -ErrorAction SilentlyContinue)) {
            "Creating user ${user}" >> $logFile
            New-LocalUser "${user}" -Password $password${user} -FullName "${user}" -Description "Description for ${user}" 2>>$logFile
            Add-LocalGroupMember -Group "Administrators" -Member "${user}" 2>>$logFile
            "User ${user} created." >> $logFile
        }
        "updating password for ${user}" >> $logFile
        Set-LocalUser -Name "${user}" -Password $password${user}
        SCRIPT
])}

        # Write the decrypted service account using google cloud secrets
        $gcpKeyFileLocationDecrypted = "c:\Windows\system32\config\systemprofile\arcgis-pro.json"

        # Fetch secret from Google Secret Manager and redirect both stdout and stderr
        $secret = gcloud secrets versions access "latest" --secret="${google_secret_manager_secret.sa_key.secret_id}" --project ${google_secret_manager_secret.sa_key.project} 2>&1

        # Write the secret to the file
        $secret | Out-File -FilePath $gcpKeyFileLocationDecrypted -Encoding utf8

        # Write the fetched secret to the file
        $secretData | Out-File -FilePath $gcpKeyFileLocationDecrypted -Encoding utf8

        # Check for the marker file "arcgis_download"
        if (-not (Test-Path "C:\arcgis_download")) {
            $gcsBucket = "arcgis-pro-${var.environment}"
            $gcsFileName = "ArcGISPro_31_184994.exe"
            "Downloading ArcGIS Pro from: gs://$gcsBucket/$gcsFileName " >> $logFile

            # Downloading the file using gsutil
            gsutil cp gs://$gcsBucket/$gcsFileName C:\$gcsFileName

            # Creating the marker file
            New-Item -Path "C:\arcgis_download" -ItemType "file" -Force
            "File downloaded and marker file created." >> $logFile
        } else {
            "File already downloaded previously." >> $logFile
        }

        # Download odbc driver
        $odbcVersion = "3.0.2.1005"
        if (-not (Test-Path "C:\odbc_downloaded-$odbcVersion")) {
            $odbcUrl = "https://storage.googleapis.com/simba-bq-release/odbc/SimbaODBCDriverforGoogleBigQuery64_$odbcVersion.msi"
            "Downloading ODBC from: $odbcUrl " >> $logFile
            $odbcInstallerPath = "C:\odbc_driver_for_bq.msi"
            "Downloading odbc installer to $odbcInstallerPath" >> $logFile
            Invoke-WebRequest -Uri $odbcUrl -OutFile $odbcInstallerPath 2>>$logFile

            # Creating the marker file
            New-Item -Path "C:\odbc_downloaded-$odbcVersion"" -ItemType "file" -Force
            "File downloaded and marker file created." >> $logFile
        } else {
            "File already downloaded previously." >> $logFile
        }

        # Check if 'dotnet' command is available
        $dotnetExists = Get-Command dotnet -ErrorAction SilentlyContinue

        if (-not $dotnetExists) {
            $dotnetVersion = $null
            "dotnet command not found." >> $logFile
        } else {
            # Attempt to get the version of dotnet installed
            $dotnetVersion = & dotnet --version 2>>$logFile
        }

        if (-not $dotnetVersion -or [version]$dotnetVersion -lt [version]"6.0.5") {
            $netRuntimeUrl = "https://download.visualstudio.microsoft.com/download/pr/1344d6ee-3e0e-43e7-ad65-61ce8bcce2de/1339c0073340fedfdd28dd9bfb9a5fb6/dotnet-sdk-6.0.414-win-x64.exe"
            $installerPath = "C:\Windows\Temp\dotnet_desktop_runtime_installer.exe"
            "Downloading .NET Desktop Runtime (x64) installer to $installerPath" >> $logFile
            Invoke-WebRequest -Uri $netRuntimeUrl -OutFile $installerPath 2>>$logFile
            "Installing .NET Desktop Runtime (x64)..." >> $logFile
            Start-Process -Wait -FilePath $installerPath -ArgumentList "/quiet /norestart" 2>>$logFile
            "Cleaning up installer..." >> $logFile
            # Remove-Item -Path $installerPath 2>>$logFile
        } else {
            ".NET version $dotnetVersion already installed." >> $logFile
        }
    EOT
}
}

# ArcGIS Pro Bucket
resource "google_storage_bucket" "arcgis" {
  name     = "arcgis-pro-${var.environment}"
  project  = var.project_id
  location = "us-central1"
  labels = {
    project_id = var.project_id
  }
}

# User secrets
resource "random_password" "user_password" {
  for_each = toset(var.user_list)

  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret" "user_passwords" {
  for_each = toset(var.user_list)
  project  = var.project_id

  secret_id = "arc-gis-pro-${each.value}"
  replication {
    auto {}
  }

  labels = {
    "environment"  = var.environment
    "terraform"    = "true"
    "manual-input" = "false"
  }
}

resource "google_secret_manager_secret_version" "user_passwords_version" {
  for_each = google_secret_manager_secret.user_passwords

  secret      = each.value.name
  secret_data = random_password.user_password[each.key].result

  lifecycle {
    ignore_changes = [secret_data]
  }
}

output "generated_passwords" {
  value     = { for user in var.user_list : user => random_password.user_password[user].result }
  sensitive = true
}

# Service Account
resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = "arcgis-pro"
  display_name = "ArcGIS Pro"
  description  = "Service account for ArcGIS Pro"
}

resource "google_service_account_key" "sa_key" {
  service_account_id = google_service_account.sa.name
}

resource "google_secret_manager_secret" "sa_key" {
  project = var.project_id

  secret_id = "arc-gis-pro-service-account-key"
  replication {
    auto {}
  }

  labels = {
    "environment"  = var.environment
    "terraform"    = "true"
    "manual-input" = "false"
  }
}

resource "google_secret_manager_secret_version" "sa_key_version" {
  secret      = google_secret_manager_secret.sa_key.name
  secret_data = google_service_account_key.sa_key.private_key
}

# Permissions
resource "google_project_iam_member" "sa_user_role" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "network_user_member" {
  project = var.network_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_secret_manager_secret_iam_member" "user-permissions" {
  for_each  = toset(var.user_list)
  secret_id = google_secret_manager_secret.user_passwords[each.key].name
  role      = "roles/secretmanager.secretAccessor"
  member    = "user:${each.value}@moove.ai"
}

resource "google_project_iam_member" "bq-user" {
  for_each = toset(var.bq_projects)
  project  = each.key
  role     = "roles/bigquery.user"
  member   = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "bq-editor" {
  for_each = toset(var.bq_projects)
  project  = each.key
  role     = "roles/bigquery.dataEditor"
  member   = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_storage_bucket_iam_member" "arcgis_bucket" {
  bucket = google_storage_bucket.arcgis.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_secret_manager_secret_iam_member" "member" {
  for_each  = toset(var.user_list)
  project   = google_secret_manager_secret.user_passwords[each.key].project
  secret_id = google_secret_manager_secret.user_passwords[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_bigquery_dataset" "dataset" {
  project       = var.project_id
  dataset_id    = "arcgis_pro_default"
  friendly_name = "ArcGIS Pro Default"
  description   = "The default dataset for ArcGIS Pro"
  location      = "US"

  labels = {
    environment = var.environment
    funnction   = "arcgis-pro"
    terraformed = "true"
  }

  access {
    role          = "OWNER"
    user_by_email = "terraform@moove-systems.iam.gserviceaccount.com"
  }

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.sa.email
  }
}

data "google_dns_managed_zone" "moove-co-in" {
  project = "moove-systems"
  name    = "moove-internal"
}

resource "google_dns_record_set" "instance_dns" {
  project      = data.google_dns_managed_zone.moove-co-in.project
  name         = "arcgis-pro.moove.co.in."
  type         = "A"
  ttl          = 300 # adjust this value if needed
  managed_zone = data.google_dns_managed_zone.moove-co-in.name

  rrdatas = [google_compute_instance.instance.network_interface[0].network_ip]
}
