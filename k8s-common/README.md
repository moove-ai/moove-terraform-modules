<!-- This README is autogenerated, any changes made will be overwritten on the next merge -->
<!-- BEGIN_TF_DOCS -->
# k8s-common

Creates common k8s resources to be used by all GKE clusters:
* argocd
* cert-manager
* external-dns
* external-secrets
* common-resources (moove)
* keda

Written by Alex Merenda for moove.ai

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the GKE cluster to be created | `string` | n/a | yes |
| <a name="input_cluster_network"></a> [cluster\_network](#input\_cluster\_network) | The VPC network the cluster is going to run in | `string` | n/a | yes |
| <a name="input_cluster_network_project_id"></a> [cluster\_network\_project\_id](#input\_cluster\_network\_project\_id) | The name of the project the VPC resides in. | `string` | n/a | yes |
| <a name="input_create_firewall_rules"></a> [create\_firewall\_rules](#input\_create\_firewall\_rules) | Set to false to disable the creation of firewall rule | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment to deploy these resources to | `string` | n/a | yes |
| <a name="input_install_argocd"></a> [install\_argocd](#input\_install\_argocd) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_cert_manager"></a> [install\_cert\_manager](#input\_install\_cert\_manager) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_cert_manager_pilot"></a> [install\_cert\_manager\_pilot](#input\_install\_cert\_manager\_pilot) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_common_resources"></a> [install\_common\_resources](#input\_install\_common\_resources) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_external_dns"></a> [install\_external\_dns](#input\_install\_external\_dns) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_external_secrets"></a> [install\_external\_secrets](#input\_install\_external\_secrets) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_external_secrets_pilot"></a> [install\_external\_secrets\_pilot](#input\_install\_external\_secrets\_pilot) | Installs helm chart. | `bool` | `true` | no |
| <a name="input_install_keda"></a> [install\_keda](#input\_install\_keda) | Set to true to install keda | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID the cluster will be deployed in | `string` | n/a | yes |
| <a name="input_proxy_dns_name"></a> [proxy\_dns\_name](#input\_proxy\_dns\_name) | The DNS Name of the GKE proxy | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP Region to deploy this module into | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->