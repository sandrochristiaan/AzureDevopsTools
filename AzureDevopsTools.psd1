# Module manifest for module 'AzureDevopsTools'

@{
    RootModule           = 'AzureDevopsTools.psm1'
    ModuleVersion        = '0.0.1'
    CompatiblePSEditions = 'Core'
    GUID                 = 'dae3f955-693c-449b-86f9-74837e41e1ba'
    Author               = 'Sandro Christiaan'
    CompanyName          = 'S Christiaan'
    Copyright            = '(c) 2023 Sandro Christiaan All rights reserved.'
    Description          = 'This module automates getting, creating & deleting resources in an Azure DevOps organization using the REST api. The goal is to provide a simple Powershell way to interact with the Azure DevOps REST api'
    PowerShellVersion    = '7.0'
    FunctionsToExport    = 'Get-AzDoProjects', 'New-AzDoProject', 'Remove-AzDoProject'
    PrivateData          = @{
        PSData = @{
            # Tags = @()
            LicenseUri               = 'https://github.com/sandrochristiaan/AzureDevopsTools/license.txt'
            ProjectUri               = 'https://github.com/sandrochristiaan/AzureDevopsTools'
            # ReleaseNotes = ''
            RequireLicenseAcceptance = $false
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}

