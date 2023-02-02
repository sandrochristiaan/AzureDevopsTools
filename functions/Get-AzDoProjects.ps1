function Get-AzDoProjects {
    <#
        .SYNOPSIS
            Get a list of projects in an Azure DevOps organization
        
        .DESCRIPTION
            Get a list of projects in an Azure DevOps organization

            Dot source this file before being able to use the function in this file. 
            To load the function into memory execute the following in the shell or create an entry in the $PROFILE:
            . .\Get-AzDoProjects.ps1
        
        .PARAMETER organizationName
            The name of the Azure DevOps organization
        
        .PARAMETER personalAccessToken
            The personal access token to use to authenticate to Azure DevOps

        .PARAMETER apiVersion
            The version of the Azure DevOps REST API to use. 
            Default value is "7.0".
        
        .EXAMPLE
            $params = @{
                organizationName = 'exampleOrganizationName'
                personalAccessToken = 'exampleAccessToken'
                apiVersion = '5.0'
            }

        .EXAMPLE
            Get-AzDoProjects -organizationName 'exampleOrganizationName' -personalAccessToken 'examplePat'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$organizationName,

        [Parameter(Position = 2, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$personalAccessToken,

        [Parameter(Position = 3)]
        [string]$apiVersion = "7.0"
    )
    
    begin {
        # Setting up variables to be used in the process block
        [string]$apiUrl = $null
        [hashtable]$header = @{}
        [string]$organizationUrl = "https://dev.azure.com/$organizationName"

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
        try {
            Write-Verbose "Getting the list of projects..."
            # Get the list of projects
            $params = @{
                Uri         = $apiUrl
                Method      = "Get"
                ContentType = "application/json"
                Headers     = $header
            }
            $listProjects = Invoke-RestMethod @params
        }
        catch {
            <#Do this if a terminating exception happens#>
        }
        if ($listProjects) {
            $projects = $listProjects.value

            Write-Verbose "Returning the list of projects..."
        } 
        else {
            $projects = @()
            Write-Verbose "No Azure DevOps projects found..."
        }

        Write-Output $projects

    }
    
    end {
        # intentionally empty 
    }
}