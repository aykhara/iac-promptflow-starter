# IaC Prompt flow Starter

This repository provides Infrastructure as Code (IaC) to automatically create the necessary Azure resources for developing and running flows in Prompt flow, using Azure Pipelines. It includes configurations and scripts that streamline the deployment process, ensuring that you have the required infrastructure set up efficiently.

## Prerequisites

- Ensure you have an Azure subscription.
- Prepare an Azure DevOps organization and project.

### 1. Configure variables

1. Update the existing Azure Pipelines YAML file `pipelines/variables.yml` if necessary.

   | Name                                    | Value (examples)                                             | Note                                                                                                                                                            |
   | --------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | group                                   | iac-promptflow-starter-variable-group                        | The name of the service connection for Azure subscription.                                                                                                      |
   | ApplicationName                         | iacpf                                                        | The name of the application.                                                                                                                                    |
   | Env                                     | dev                                                          | The environment in which the application is deployed.                                                                                                           |
   | ReleaseId                               | 001                                                          | The release identifier.                                                                                                                                         |
   | OpenAiLocation                          | westus3                                                      | The location of the OpenAI resource. ([Ref](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#standard-deployment-model-availability)) |
   | OpenAiSku                               | S0                                                           | The SKU for the OpenAI resource.                                                                                                                                |
   | Gpt4ModelCapacity                       | 10                                                           | The capacity of the GPT-4 model.                                                                                                                                |
   | Gpt4ModelVersion                        | 1106-Preview                                                 | The version of the GPT-4 model.                                                                                                                                 |
   | AiProjectSku                            | Basic                                                        | The SKU for the AI project.                                                                                                                                     |
   | AiProjectConnectionAiServicesName       | AzureAIServices_Connection_IaC                               | The name of the AI services connection.                                                                                                                         |
   | AiProjectConnectionOpenAiName           | AzureOpenAI_Connection_IaC                                   | The name of the OpenAI connection.                                                                                                                              |
   | AiProjectConnectionDeplpymentOpenAiName | gpt-4                                                        | The name of the OpenAI deployment connection.                                                                                                                   |
   | AiHubFriendlyName                       | "AI resource (IaC test)"                                     | A friendly name for the AI resource.                                                                                                                            |
   | AiHubDescription                        | "This is an example AI resource for use in Azure AI Studio." | A description of the AI resource.                                                                                                                               |

## 2. Set up Azure DevOps

1. Sign in to your Azure DevOps organization and go to your project.

1. Go to **Project Settings**, and then select **Service connections** under Pipelines. You need to set up the following two service connections:

   1. **Azure Resource Manager** to access Azure resources:

      1. Create a service connection.
      1. Select **Azure Resource Manager**.
      1. Select **Service principal (automatic)**.
      1. Select Scope level - **Subscription**, choose the appropriate subscription and resource group, and name the service connection (e.g., `azure-iac-promptflow-starter-service-connection`).
      1. Select **Save**.

   1. **GitHub** to access GitHub repositories:
      1. Select **New service connection**.
      1. Select **GitHub**.
      1. Select **Grant authorization**, choose **AzurePipelines** for OAuth Configuration, and authorize it.
      1. You might be redirected to GitHub to authorize AzurePipelines.
      1. Select **Save**.

1. Go to **Pipelines**, select **Library**, and then create a new variable group.

   1. Name the variable group (e.g., `iac-promptflow-starter-variable-group`, with the same name as the group in `variables.yml`).
   1. Add the following variables:

   | Name     | Value                                                   |
   | -------- | ------------------------------------------------------- |
   | AZURESVC | e.g., `azure-iac-promptflow-starter-service-connection` |

1. Go to **Pipelines**, and then select **New pipeline** or **Create pipeline** if creating your first pipeline.

1. Follow the steps in the wizard by first selecting GitHub as the location of your source code. When you see the list of repositories, search for your GitHub repo and select it.

1. Assign your pipeline to either Production or Non-production, and then configure the pipeline.

1. Select **Existing Azure Pipelines YAML file** (files will be shown only on the main branch).

1. Select the existing Azure Pipelines YAML file `pipelines/iac_pipeline.yml` in the repository.

1. Select **Review pipeline**.

1. Name the pipeline (e.g., `IaC (Prompt flow)`), and then **Save and run**.

## Tips

### Quota limit for AOAI models

If the quota limit for the AOAI model is reached, and deployment is not possible in the specified region (`variables.yml - OpenAiLocation`), you may need to consider changing to a different region. The usage of each model's quota can be checked in Azure OpenAI Studio > Quotas. ([Ref](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#standard-and-global-standard-deployment-model-quota))

#### Example Error

Inner Errors:

```json
{
  "code": "InsufficientQuota",
  "message": "This operation requires 10 new capacity in quota Tokens Per Minute (thousands) - GPT-4, which is bigger than the current available capacity 0. The current quota usage is 40 and the quota limit is 40 for quota Tokens Per Minute (thousands) - GPT-4."
}
```
