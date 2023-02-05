#dot source functions
Get-ChildItem $PSScriptRoot\functions\*.ps1 -Recurse |
ForEach-Object {
    . $_.FullName
}