
<#
    .Synopsis
        Get an access token
	.Description
        Gets an access token to perform action in the safe

	.Parameter Creds
        Credential to carry out this action

	.Parameter DefaultBaseURL

    .Parameter RADIUS


    .Example
        Get-Token -Creds (get-credential) -RADIUS -Outvariable SessionID

    Description
	---------------------


    .Link

    .Notes
        Author:  Johnny Leuthard
        Version: 1.0

#>
Function Get-RESTToken
{
  [cmdletbinding()]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [alias("Cred", "Token")]
    [PSCredential]$Creds,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    $BaseURL = $DefaultBaseURL,
    [switch]$RADIUS
  )
  Begin
  {

    $UseRadiusAuthentication = $false
    If ($RADIUS)
    {$UseRadiusAuthentication = $true}

    # Set Username and password from the $Creds variable
    $global:Username = $Creds.UserName
    $Global:Password = $Creds.getnetworkCredential().Password

    # Web URL for the get token API
    $URL = "https://$BaseURL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

  }#(begin)
  Process
  {

    # Hashtable / Dictionary to pass off to the API Service
    $bodyParams = [ordered]@{username = $Username; password = $password; UseRadiusAuthentication = $UseRadiusAuthentication} | ConvertTo-JSON

    # Execute REST call
    try
    {
      $Global:logonResult = Invoke-RestMethod -Uri $URL -Method POST -ContentType "application/json" -Body $bodyParams
    }
    catch
    {
      $ErrorHash = [ordered]@{
        "Date"              = (Get-Date -f mm/dd/yyyy)
        "Time"              = (Get-Date -f hh:mm:ss)
        "DateUTC"           = (get-date -Format o)
        "Action"            = $MyInvocation.MyCommand.Name
        #"ObjectInfo" = ("Username: " + $Creds.username)
        "StatusCode"        = $_.Exception.Response.StatusCode.Value__
        "StatusDescription" = $_.Exception.Response.StatusDescription
        "Response"          = $_.Exception.Message
        "RADIUS"            = $UseRadiusAuthentication
        "BAseURL"           = $BaseURL
        "Token"             = "NO TOKEN??"
      }#($ErrorHash)
      $ErrorData = New-Object -TypeName psobject -Property $ErrorHash
      # Write-error $errordata
      $ErrorData
      break
    }#(Try...Catch)

　
　
    # Has table of redults & convert to object
    $Hash = [ordered]@{
        "Username"  = $Creds.UserName
        "DateUTC"   = (get-date -Format o)
        "Action"    = $MyInvocation.MyCommand.Name
        #"ObjectInfo" = ("Username: " + $Creds.username)
        "Obtained" = (get-date)
        "RADIUS"   = $UseRadiusAuthentication
        "BAseURL"  = $BaseURL
        "Token"    = "NO TOKEN??"
    }
    New-Object -TypeName psobject -Property $Hash

  }#(Process)
  end
  {

　
  }#(End)
}#(Function)
#####################
### NOTES
#####################
<#

To Do
---------
- Encrypt token for when it is passed back and forth?

　
$DemoCreds = Get-Credential -Message "User ID you want the token for"

$sessionID = Get-RESTToken -Creds $DemoCreds

　
　
#>

　

