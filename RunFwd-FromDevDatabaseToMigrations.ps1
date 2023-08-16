$text = @"

                         _)\.-.                                
         .-.__,___,_.-=-. )\`  a`\_                            
     .-.__\__,__,__.-=-. `/  \     `\     ___  _ _ _  ___      
    {~,-~-,-~.-~,-,;;;;\ |   '--;`)/     | __|| | | || _ \     
    \-,~_-~_-,~-,(_(_(;\/   ,;/         | _| | | | |||_| |     
     ",-.~_,-~,-~,)_)_)'.  ;;(          |_|  \_____/|___/     
        `~-,_-~,-~(_(_(_(_\  `;\                              
        
"@
#Created by: THR-2023-@promicroNL

Write-Host $text

# Specify the paths to the EF Core and Flyway migration files
$flywayProjectPath = "C:\work\EFCore2FlywayDesktop\Flyway_alt\"
$flywayProjectMigrationPath = Join-Path $flywayProjectPath "Migrations"

# Apply the dev database to schema-model

# Define temporary diff file and path
$diffArtifactFileName = New-Guid 
$tempFilePath = Join-Path $env:LOCALAPPDATA "Temp\Redgate\Flyway Desktop\comparison_artifacts_Dev_SchemaModel" 
$null = New-Item -ItemType Directory -Force -Path $tempFilePath
$diffArtifactFilePath = Join-Path $tempFilePath $diffArtifactFileName

# Parameters for Flyway dev
$commonParams =
@("--artifact=$diffArtifactFilePath",
"--project=$flywayProjectPath",
"--i-agree-to-the-eula")

$diffParams = @("diff", "--from=Dev" ,"--to=SchemaModel") + $commonParams
$takeParams = @("take") + $commonParams
$applyParams = @("apply") + $commonParams

flyway-dev @diffParams
flyway-dev @takeParams | flyway-dev @applyParams

Remove-Item $diffArtifactFilePath

#now create migrations for these steps
Write-Host "--------------------> NEXT, let's make migrations" 

# Define temporary diff file and path
$tempFilePath = Join-Path $env:LOCALAPPDATA "Temp\Redgate\Flyway Desktop\comparison_artifacts_SchemaModel_Migrations"
$diffArtifactFileName = New-Guid 
$null = New-Item -ItemType Directory -Force -Path $tempFilePath
$diffArtifactFilePath = Join-Path $tempFilePath  $diffArtifactFileName

# Parameters for Flyway dev
$commonParams =
@("--artifact=$diffArtifactFilePath",
"--project=$flywayProjectPath",
"--i-agree-to-the-eula")

$diffParams = @("diff", "--from=SchemaModel", "--to=Migrations") + $commonParams
$generateParams = @("generate", "--outputFolder=$flywayProjectMigrationPath", "--changes", "-")+ $commonParams
$takeParams = @("take") + $commonParams

flyway-dev @diffParams
flyway-dev @takeParams | flyway-dev @generateParams

Remove-Item $diffArtifactFilePath

# to make it smarter
# $result = Invoke-Expression $takeAndGenerate

# Write-host $result | ConvertFrom-Json
