// --------------------------------------------------
// Parameters
param env string
param app_name string
param release_id string

@description('Azure region of the deployment (OpenAI)')
param openai_location string

@description('Azure OpenAI SKU')
param openai_sku string

@description('The capacity of the GPT-4 model')
param gpt4_model_capacity int

@description('The version of the GPT-4 model')
param gpt4_model_version string

@description('AI Project SKU name')
param aiproject_sku string

@description('AI Project Connection name (AI Services)')
param aiproject_connection_aiservices_name string

@description('AI Project Connection name (OpenAI)')
param aiproject_connection_openai_name string

@description('AI Project Connection Deployment name (OpenAI)')
param aiproject_connection_deployment_openai_name string

@description('Friendly name for your Azure AI resource')
param aihub_friendly_name string

@description('Description of your Azure AI resource dispayed in AI studio')
param aihub_description string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

// --------------------------------------------------
// Variables
var aihub_name = 'aih-${app_name}-${env}-${release_id}'
var aiproject_name = 'aip-${app_name}-${env}-${release_id}'
var aiservice_name = 'ais-${app_name}-${env}-${release_id}'
var openai_name = 'oai-${app_name}-${env}-${release_id}'
var st_name = replace('st-${app_name}-${env}-${release_id}', '-', '')
var kv_name = 'kv-${app_name}-${env}-${release_id}'
var log_name = 'log-${app_name}-${env}-${release_id}'
var appi_name = 'appi-${app_name}-${env}-${release_id}'
var cr_name = replace('cr-${app_name}-${env}-${release_id}', '-', '')

// --------------------------------------------------
// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${app_name}-${env}-${release_id}-deployment'
  params: {
    location: location
    storageName: st_name
    keyvaultName: kv_name
    logAnalyticsWorkspaceName: log_name
    applicationInsightsName: appi_name
    containerRegistryName: cr_name
    aiServicesName: aiservice_name
    openAiLocation: openai_location
    openAiName: openai_name
    openAiSku: openai_sku
    gpt4ModelCapacity: gpt4_model_capacity
    gpt4ModelVersion: gpt4_model_version
    tags: tags
  }
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'ai-${app_name}-${env}-${release_id}-deployment'
  params: {
    // workspace organization
    location: location
    aiHubName: aihub_name
    aiHubFriendlyName: aihub_friendly_name
    aiHubDescription: aihub_description
    aiProjectName: aiproject_name
    aiProjectSkuName: aiproject_sku
    aiProjectConnectionAiServicesName: aiproject_connection_aiservices_name
    aiProjectConnectionOpenAiName: aiproject_connection_openai_name
    aiProjectConnectionDeploymentOpenAiName: aiproject_connection_deployment_openai_name
    openAiName: openai_name
    gpt4ModelCapacity: gpt4_model_capacity
    gpt4ModelVersion: gpt4_model_version
    tags: tags

    // dependent resources
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    openAiID: aiDependencies.outputs.openAiID
  }
}
