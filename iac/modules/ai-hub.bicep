// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

// --------------------------------------------------
// Parameters
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string

@description('AI hub description')
param aiHubDescription string

@description('AI project name')
param aiProjectName string

@description('AI project display name')
param aiProjectFriendlyName string = aiProjectName

@description('AI Project SKU name')
param aiProjectSkuName string

@description('AI Project Connection name (AI Services)')
param aiProjectConnectionAiServicesName string

@description('AI Project Connection name (OpenAI)')
param aiProjectConnectionOpenAiName string

@description('AI Project Connection Deployment name (OpenAI)')
param aiProjectConnectionDeploymentOpenAiName string

@description('The capacity of the GPT-4 model')
param gpt4ModelCapacity int

@description('The version of the GPT-4 model')
param gpt4ModelVersion string

@description('Azure OpenAI services name')
param openAiName string

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Resource ID of the Azure OpenAI Services endpoint')
param openAiID string


// --------------------------------------------------
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
  }
  kind: 'hub'
}

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiProjectName
  location: location
  sku: {
    name: aiProjectSkuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'AI Project Workspace'
    friendlyName: aiProjectFriendlyName
    hubResourceId: aiHub.id
  }
  kind: 'project'

  resource aiProjectConnectionAiServices 'connections@2024-01-01-preview' = {
    name: aiProjectConnectionAiServicesName
    properties: {
      category: 'AzureOpenAI'
      target: aiServicesTarget
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }

  resource aiProjectConnectionOpenAi 'connections@2024-04-01' = {
    name: aiProjectConnectionOpenAiName
    properties: {
      category: 'AzureOpenAI'
      target: 'https://${openAiName}.openai.azure.com/'
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(openAiID, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ProvisioningState: 'Succeeded'
        ResourceId: openAiID
        ApiVersion: '2023-07-01-preview'
        DeploymentApiVersion: '2023-10-01-preview'
      }
    }

    resource aiProjectConnectionDeployment 'deployments@2024-04-01-preview' = {
      name: aiProjectConnectionDeploymentOpenAiName
      properties: {
        sku: {
          name: 'Standard'
          capacity: gpt4ModelCapacity
        }
        type: 'Azure.OpenAI'
        model: {
          format: 'OpenAI'
          name: 'gpt-4'
          version: gpt4ModelVersion
        }
        versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
        raiPolicyName: 'CustomContentFilter'
      }
    }

    resource customContentFilter 'raiPolicies@2024-04-01-preview' = {
      name: 'ustomContentFilter'
      properties: {
        mode: 'Default'
        contentFilters: [
          {
            name: 'hate'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Prompt'
          }
          {
            name: 'sexual'
            allowedContentLevel: 'Medium'
            blocking: false
            enabled: true
            source: 'Prompt'
          }
          {
            name: 'selfharm'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Prompt'
          }
          {
            name: 'violence'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Prompt'
          }
          {
            name: 'hate'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Completion'
          }
          {
            name: 'sexual'
            allowedContentLevel: 'Medium'
            blocking: false
            enabled: true
            source: 'Completion'
          }
          {
            name: 'selfharm'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Completion'
          }
          {
            name: 'violence'
            allowedContentLevel: 'Medium'
            blocking: true
            enabled: true
            source: 'Completion'
          }
          {
            name: 'indirect_attack'
            blocking: true
            enabled: true
            source: 'Prompt'
          }
          {
            name: 'jailbreak'
            blocking: true
            enabled: true
            source: 'Prompt'
          }
        ]
      }
    }
  }
}

output aiProjectID string = aiProject.id
output aiHubID string = aiHub.id
