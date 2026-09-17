# Automated Data Import — Sanitized Portfolio Demo
# IMPORTANT:
# This is a sanitized portfolio version. It does not contain production credentials,
# server names, database names, internal file paths, or executable paths.

param(
    [string]$ServerName = "YOUR_SQL_SERVER",
    [string]$Database = "YOUR_DATABASE",
    [string]$DbLogin = "YOUR_DB_LOGIN",
    [string]$DbPassword = "YOUR_DB_PASSWORD",
    [string]$ApplicationExePath = "C:\Path\To\Application.exe",
    [string]$ApplicationUser = "YOUR_APP_USER",
    [string]$ApplicationPassword = "YOUR_APP_PASSWORD",
    [string]$DataSourcesFilePath = "C:\Path\To\datasources.txt"
)

# Retrieve the closed accounting period from the database.
$query = @"
SELECT TOP 1 [Value]
FROM [SystemSettings]
WHERE [Key] = 'CLOSEDPERIOD/closeDate'
"@

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = `
    "Server=$ServerName;Database=$Database;User ID=$DbLogin;Password=$DbPassword;"

try {
    $connection.Open()

    $command = New-Object System.Data.SqlClient.SqlCommand
    $command.Connection = $connection
    $command.CommandText = $query

    $result = $command.ExecuteScalar()

    if ($null -eq $result) {
        throw "Closed period date was not found."
    }

    Write-Host "Closed period date: $result"
}
catch {
    Write-Error "Failed to retrieve closed period date: $_"
    exit 1
}
finally {
    if ($connection.State -eq [System.Data.ConnectionState]::Open) {
        $connection.Close()
    }
}

# Business rule:
# Import starts on the day after the closed accounting period.
try {
    $startDate = ([DateTime]::ParseExact(
        $result,
        'dd.MM.yyyy',
        $null
    )).AddDays(1)

    $startDateString = $startDate.ToString('dd.MM.yyyy')
    Write-Host "Import start date: $startDateString"
}
catch {
    Write-Error "Failed to process closed period date: $_"
    exit 1
}

# In the original workflow, "0" means import through the current date.
$endDateString = "0"

$args = @(
    "-action=import",
    "-database=`"$Database`"",
    "-user=`"$ApplicationUser`"",
    "-password=`"$ApplicationPassword`"",
    "-datasources=`"$DataSourcesFilePath`"",
    "-startdate=`"$startDateString`"",
    "-enddate=`"$endDateString`""
) -join " "

# Start the application import and wait for completion.
Start-Process `
    -FilePath $ApplicationExePath `
    -ArgumentList $args `
    -Wait `
    -NoNewWindow
