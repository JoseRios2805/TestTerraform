provider "azurerm" {
 version = "=3.83.0" 
 features {}
}

resource "azurerm_resource_group" "rsPrueba" {
 name     = "myrsprueba"
 location = "East US"
}

resource "azurerm_virtual_network" "vnPrueba" {
 name                = "myvnetprueba"
 address_space       = ["10.0.0.0/16"]
 resource_group_name = azurerm_resource_group.rsPrueba.name
 location            = azurerm_resource_group.rsPrueba.location

   subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24" 
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24" 
  }
}

resource "azurerm_data_factory" "dfPrueba" {
 name                = "mydfprueba"
 location            = azurerm_resource_group.rsPrueba.location
 resource_group_name = azurerm_resource_group.rsPrueba.name
}

resource "azurerm_storage_account" "saPrueba" {
 name                     = "mysaprueba"
 resource_group_name      = azurerm_resource_group.rsPrueba.name
 location                 = azurerm_resource_group.rsPrueba.location
 account_tier             = "Standard"
 account_replication_type = "LRS"
 account_kind             = "StorageV2"
 is_hns_enabled           = "true"
}

resource "azurerm_sql_server" "sqlPrueba" {
 name                         = "mysqlprueba"
 resource_group_name          = azurerm_resource_group.rsPrueba.name
 location                     = azurerm_resource_group.rsPrueba.location
 version                      = "12.0"
 administrator_login          = "4dm1n157r470r"
 administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_subnet" "replica" {
  name                 = "replica-subnet"
  resource_group_name  = azurerm_resource_group.rsPrueba.name
  virtual_network_name = azurerm_virtual_network.vnPrueba.name
  address_prefixes     = ["10.0.2.0/24"] 
}

resource "azurerm_active_directory_domain_service" "adPrueba" {
 name                = "myadprueba"
 location            = azurerm_resource_group.rsPrueba.location
 resource_group_name = azurerm_resource_group.rsPrueba.name

 domain_name           = "mydomain.com"
 sku                   = "Standard"

initial_replica_set {
    subnet_id = azurerm_subnet.replica.id
}

tags = {
    environment = "test"
    }
}

resource "azurerm_key_vault" "kvPrueba" {
 name                     = "mykeyvaultprueba"
 location                 = azurerm_resource_group.rsPrueba.location
 resource_group_name      = azurerm_resource_group.rsPrueba.name
 tenant_id                = "5c57aae5-8f37-41aa-a44a-928ebe7d6baf"

 sku_name = "standard"

 access_policy {
    tenant_id = "5c57aae5-8f37-41aa-a44a-928ebe7d6baf"
    object_id = "5bdbc1c7-230a-4f00-acd7-742b5bd1a61e"

    key_permissions = [
      "Get",
      "List",
    ]
 }
}