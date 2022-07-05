provider "azurerm" {
  features {}
}

module "rg" {
  source  = "bcochofel/resource-group/azurerm"
  version = "1.4.0"

  name     = "rg-aks-spot-node-pool-${var.cluster_name}"
  location = var.aks_region
}

module "aks" {
  source = "../azurerm-aks/"

  name                = var.cluster_name
  resource_group_name = module.rg.name
  dns_prefix          = "kubify"

  default_pool_name = "spot"

  node_pools = [
    {
      name            = "spot"
      priority        = "Spot"
      eviction_policy = "Delete"
      spot_max_price  = 0.2
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = [
        "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
      ]
      node_count = 1
    }
  ]

  depends_on = [module.rg]
}

######

# module "network" {
#   source              = "Azure/network/azurerm"
#   resource_group_name = azurerm_resource_group.example.name
#   address_space       = "10.52.0.0/16"
#   subnet_prefixes     = ["10.52.0.0/24"]
#   subnet_names        = ["subnet1"]
#   depends_on          = [azurerm_resource_group.example]
# }

# data "azuread_group" "aks_cluster_admins" {
#   display_name = "kubify-${var.cluster_name}-aks-cluster-admins"
# }

# # TODO: spot
# module "aks" {
#   source                           = "Azure/aks/azurerm"
#   resource_group_name              = azurerm_resource_group.example.name
#   client_id                        = "your-service-principal-client-appid"
#   client_secret                    = "your-service-principal-client-password"
#   kubernetes_version               = "1.23.5"
#   orchestrator_version             = "1.23.5"
#   prefix                           = "prefix"
#   default_pool_name                = "spot"
#   node_pools = [
#     {
#       name            = "spot"
#       priority        = "Spot"
#       eviction_policy = "Delete"
#       spot_max_price  = 0.1
#       node_labels = {
#         "kubernetes.azure.com/scalesetpriority" = "spot"
#       }
#       node_taints = [
#         "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
#       ]
#       node_count = 1
#     }
#   ]


#   cluster_name                     = var.cluster_name
#   network_plugin                   = "azure"
#   vnet_subnet_id                   = module.network.vnet_subnets[0]
#   os_disk_size_gb                  = 50
#   sku_tier                         = "Free" # defaults to Free (can also be "Paid")
#   enable_role_based_access_control = true
#   rbac_aad_admin_group_object_ids  = [data.azuread_group.aks_cluster_admins.id]
#   rbac_aad_managed                 = true
#   private_cluster_enabled          = true # default value
#   enable_http_application_routing  = true
#   enable_azure_policy              = true
#   enable_auto_scaling              = true
#   enable_host_encryption           = true
#   agents_min_count                 = 1
#   agents_max_count                 = 2
#   agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
#   agents_max_pods                  = 100
#   agents_pool_name                 = "aks-ng-cpu-${var.cluster_name}"
#   agents_availability_zones        = ["1", "2"]
#   agents_type                      = "VirtualMachineScaleSets"

#   agents_labels = {
#     "nodepool" : "defaultnodepool"
#   }

#   agents_tags = {
#     "Agent" : "defaultnodepoolagent"
#   }

#   enable_ingress_application_gateway      = true
#   ingress_application_gateway_name        = "aks-agw-${var.cluster_name}"
#   ingress_application_gateway_subnet_cidr = "10.52.1.0/24"

#   network_policy                 = "azure"
#   net_profile_dns_service_ip     = "10.0.0.10"
#   net_profile_docker_bridge_cidr = "170.10.0.1/16"
#   net_profile_service_cidr       = "10.0.0.0/16"

#   depends_on = [module.network]
# }