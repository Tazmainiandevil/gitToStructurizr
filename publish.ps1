<#
.SYNOPSIS
    PowerShell script to upload diagram changes to Structurizr Cloud

.DESCRIPTION
    This PowerShell script works out the changes between git commits where the files are of extension .dsl and upload to Structurizr Cloud
    and optionally creates SVG files of the changes

.PARAMETER StartCommitId
    The commit hash of the starting commit to look for changes

.PARAMETER CommitId
    The commit has of the end commit to look for changes

.PARAMETER DownloadFolder
    The folder to use as the download folder

.PARAMETER FolderAsId
    A boolean flag to denote if the Structurizr workspace ID is the folder name

.PARAMETER CreateImages
    A boolean flag to denote if SVG files should be created ready for upload

.EXAMPLE
    Example syntax for running the script or function
    PS C:\> ./publish.ps1 -StartCommitId $startCommitHash -CommitId $commitHash -DownloadFolder 'downloads' -FolderAsId $false CreateImages $false
#>

param (
    [Parameter(Mandatory)]
    [string]$StartCommitId,
    [Parameter(Mandatory)]
    [string]$CommitId,
    [Parameter(Mandatory)]
    [string]$DownloadFolder = 'downloads',
    [bool]$FolderAsId = $false,
    [bool]$CreateImages = $false
)

git diff-tree --no-commit-id --name-only --diff-filter=cd -r "$StartCommitId..$CommitId" | Where-Object { $_.EndsWith('.dsl') } | Foreach-Object {

    $filePath = ($_ | Resolve-Path -Relative) -replace "^./"
    $workspaceFolder = Split-Path -Path $filePath -Parent 
    $workspaceFile = $filePath 
    Write-Host "folder: $workspaceFolder"
    Write-Host "file: $workspaceFile"

    if ( $FolderAsId -eq $true ) {
        $workspaceIdValue = $workspaceFolder
    }
    else {
        $workspaceId = "WORKSPACE_ID_$($workspaceFolder)".ToUpper()
        $workspaceIdValue = (Get-item env:$workspaceId).Value
    }
    
    $workspaceKey = "WORKSPACE_KEY_$($workspaceFolder)".ToUpper()
    $workspaceKeyValue = (Get-item env:$workspaceKey).Value

    $workspaceSecret = "WORKSPACE_SECRET_$($workspaceFolder)".ToUpper()
    $workspaceSecretValue = (Get-item env:$workspaceSecret).Value

    docker run -i --rm -v ${pwd}:/usr/local/structurizr structurizr/cli push -id $workspaceIdValue -key $workspaceKeyValue -secret $workspaceSecretValue -workspace $workspaceFile
    $outputPath = "$DownloadFolder/$workspaceIdValue"
    if ( $CreateImages -eq $true ) {
        docker run --rm -v ${pwd}:/usr/local/structurizr structurizr/cli export -workspace $workspaceFile -format dot -output $outputPath
        sudo chown ${env:USER}:${env:USER} $outputPath

        Write-Host 'Convert exported files to svg'
        Get-ChildItem -Path $outputPath | Foreach-Object {
            $exportPath = ($_ | Resolve-Path -Relative)
            $folder = Split-Path -Path $exportPath -Parent
            $name = Split-Path -Path $exportPath -LeafBase

            Write-Host "Writing file: $folder/$name.svg"
            dot -Tsvg $exportPath > $folder/$name.svg
            rm $exportPath
        }
    }
}
