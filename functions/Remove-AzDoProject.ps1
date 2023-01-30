function Remove-AzDoProject {
    <#
        .SYNOPSIS
            Deletes an Azure DevOps Project using the Project Id

        .DESCRIPTION
            Deletes an Azure DevOps Project using the Project Id

        .PARAMETER organizationName
            The name of the Azure DevOps organization

        .PARAMETER projectId
            The id of the Azure DevOps Project

        .PARAMETER personalAccessToken
            The personal access token to use to authenticate to Azure DevOps

        .PARAMETER apiVersion    
            The version of the Azure DevOps REST API to use. 
            Default value is "7.0".
        
        .EXAMPLE
            $params = @{
                organizationName = 'exampleOrganizationName'
                projectId = '8b2b0fed-0287-43a3-9308-31880428d374'
                personalAccessToken = 'examplePat'
            }
            Remove-AzDoProject @params

        .EXAMPLE
            Remove-AzDoProject -organizationName 'someOrganizationName' -projectId '<guid of project to be deleted>' -personalAccessToken '<access token>'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$organizationName,

        [Parameter(Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$projectId,

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
        [string]$apiUrl = -join ($organizationUrl, "/_apis/projects/", $projectId, "?api-version=", $apiVersion)

        # Create header with PAT
        Write-Verbose "Creating header with PAT..."
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
        [hashtable]$header = @{
            authorization = "Basic $token"
        }
    }
    
    process {
        $params = @{
            Method      = "Delete"
            ContentType = "application/json"
            Headers     = $header
            Uri         = $apiUrl
        }

        try {
            Write-Verbose "Deleting Azure DevOps Project using id: $projectId..."
            $response = Invoke-RestMethod @params
        }
        catch {
            if ( $_.Exception.Response.StatusCode.value__ -eq 404 ) {
                Write-Warning "Azure DevOps Project id: $projectId not found..."
            }
            else {
                Write-Error $_
            }
        }
    }
    
    end {
        Write-Verbose "Delete Operation completed..."
    }
}