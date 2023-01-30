function New-AzDoProject {
    <#
        .SYNOPSIS
            Creates a new Azure DevOps project
        
        .DESCRIPTION
            Creates a new Azure DevOps project

        .PARAMETER organizationName
            The name of the Azure DevOps organization

        .PARAMETER projectName
            The name of the Azure DevOps project
        
        .PARAMETER visibility
            The visibility of the Azure DevOps project. 
            Valid values are 'private' and 'public'. Default value is 'private'.

        .PARAMETER processTemplate
            The process template of the Azure DevOps project. 
            Valid values are 'basic', 'agile', 'cmmi', and 'scrum'. Default value is 'agile'.

        .PARAMETER personalAccessToken
            The personal access token to use to authenticate to Azure DevOps

        .PARAMETER sourceControl
            The source control type of the Azure DevOps project. Valid values are 'git' and 'tfvc'. Default value is 'git'.

        .PARAMETER description
            The description of the Azure DevOps project. 
            Default value is "Default description: Azure DevOps Project for '$($projectName)' created via REST API - PowerShell".

        .PARAMETER apiVersion
            The version of the Azure DevOps REST API to use. 
            Default value is "7.0".
        
        .EXAMPLE
            $params = @{
                organizationName = 'exampleOrganizationName'
                projectName = 'exampleProjectName'
                visibility = 'private'
                processTemplate = 'agile'
                personalAccessToken = 'examplePat'
                sourceControl = 'git'
                description = "An example description"
                apiVersion = "7.0"
            }
            New-AzDoProject @params

        .EXAMPLE
            New-AzDoProject -organizationName 'someOtherOrgName' -projectName 'awesomeProjectName' -personalAccessToken 'myAccessToken'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$organizationName,

        [Parameter(Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$projectName,

        [Parameter(Position = 2)]
        [ValidateSet('private', 'public')]
        [string]$visibility = 'private',

        [Parameter(Position = 3)]
        [ValidateSet('basic', 'agile', 'cmmi', 'scrum')]
        [string]$processTemplate = 'agile',

        [Parameter(Position = 4, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$personalAccessToken,

        [Parameter(Position = 5)]
        [ValidateSet('git', 'tfvc')]
        [string]$sourceControl = 'git',

        [Parameter(Position = 6)]
        [string]$description = "Default description: Azure DevOps Project for '$($projectName)' created via REST API - PowerShell",

        [Parameter(Position = 7)]
        [string]$apiVersion = "7.0"
    )
    
    begin {
        # Setting up variables to be used in the process block
        [string]$apiUrl = $null
        [hashtable]$header = @{}

        [string]$organizationUrl = "https://dev.azure.com/$organizationName"
        
        switch ($processTemplate) {
            "basic" {
                $templateType = "b8a3a935-7e91-48b8-a94c-606d37c3e9f2"
            }
            "agile" {
                $templateType = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
            }
            "cmmi" {
                $templateType = "27450541-8e31-4150-9947-dc59f998fc01"
            }
            "scrum" {
                $templateType = "6b724908-ef14-45cf-84f8-768b5384da45"
            }
            default {
                # default to basic
                $templateType = "b8a3a935-7e91-48b8-a94c-606d37c3e9f2"
            }
        }

        Write-Verbose "Constructing Azure DevOps API url..."
        [string]$apiUrl = -join ($organizationUrl, "/_apis/projects?api-version=", $apiVersion)

        # Create header with PAT
        Write-Verbose "Creating header with PAT..."
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
        [hashtable]$header = @{
            authorization = "Basic $token"
        }

    }
    
    process {
        $params = @{
            Method      = "Post"
            ContentType = "application/json"
            Headers     = $header
            Uri         = $apiUrl
        }

        try {
            $body = @{
                name         = $projectName
                description  = $description
                visibility   = $visibility
                capabilities = @{
                    versioncontrol  = @{
                        sourceControlType = $sourceControl
                    }
                    processTemplate = @{
                        templateTypeId = $templateType
                    }
                }
            } | ConvertTo-Json
        
            $params.Body = $body
            
            Write-Verbose "Creating project $projectName..."
            $response = Invoke-RestMethod @params
        }
        catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 400) {
                Write-Verbose "The Azure Devops Project: '$($projectName)' already exists..."
                $errormsg = $_.ErrorDetails.Message | ConvertFrom-Json
                Write-Verbose "$($errormsg.message)"
            }
            else {
                Write-Verbose $_
            }
        }
    }
    
    end {
        Write-Verbose "Project '$($projectName)' created successfully..."
        Write-Output $response
    }
}

