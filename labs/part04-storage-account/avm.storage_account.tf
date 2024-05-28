module "storage_account" {
  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~> 0.1"
  account_replication_type          = "LRS"
  location                          = azurerm_resource_group.this.location
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.this.name
  infrastructure_encryption_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [module.azurerm_user_assigned_identity.resource_id]
  }
  customer_managed_key = {
    key_vault_resource_id  = module.key_vault.resource.id
    key_name               = module.key_vault.resource_keys["cmk_for_storage_account"].name
    user_assigned_identity = { resource_id = module.azurerm_user_assigned_identity.resource_id }
  }
  containers = {
    demo = {
      name                  = "demo"
      container_access_type = "private"
      role_assignments = {
        contributor = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = module.virtual_machine.virtual_machine_azurerm.identity[0].principal_id
        }
      }
    }
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone_storage_account.private_dnz_zone_output.id]
      subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
    }
  }
}
