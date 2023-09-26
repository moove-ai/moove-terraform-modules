locals {
  flattened_dataset_roles = flatten([
    for environment, projects in var.dataset_roles : [
      for project, datasets in projects : [
        for dataset, roles in datasets : [
          for role in roles : {
            "key"         = "${environment}-${project}-${dataset}-${role}",
            "project"     = project,
            "dataset"     = dataset,
            "role"        = role,
            "environment" = environment
          }
        ]
      ]
    ]
  ])
  dataset_role_map = { for item in local.flattened_dataset_roles : item.key => item }
}

resource "google_bigquery_dataset_iam_member" "member" {
  for_each = local.dataset_role_map

  project    = each.value.project
  dataset_id = each.value.dataset
  role       = each.value.role

  # Use the environment from each.value to look up the service account from var.environments
  member = "serviceAccount:${var.environments[each.value.environment].function_service_account}"
}
