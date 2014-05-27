# Powershell script to fetch a list of autostarted services via WMI and report back in a JSON
# formatted message that Zabbix will understand for Low Level Discovery purposes.

param([string]$regex = "regex", [string]$sun = "sun")


#Write-Host "$regex"
#Write-Host "$sun"

# First, fetch the list of auto started services
$colItems = Get-WmiObject Win32_Service | where-object { $_.StartMode -ne 'Disabled' }
# Output the JSON header
Write-Host "{";
write-host "`t ""data"":[";
write-host


# For each object in the list of services, print the output of the JSON message with the object properties that we are interessted in
foreach ($objItem in $colItems) {
	$exe_dir = $objItem.PathName
	$exe_dir = $exe_dir -replace '"?(.+\\).+exe.*','$1'
	$exe_dir = $exe_dir -replace '\\','/'
	
	# Remove text with "text" from the Description
	$desc_val = $objItem.Description
	$desc_val = $desc_val -replace '\"','@'
 
	$line = " { `"{#SERVICESTATE_$sun}`":`"" + $objItem.State + "`", `"{#SERVICEDISPLAY_$sun}`":`"" + $objItem.DisplayName + "`", `"{#SERVICENAME_$sun}`":`"" + $objItem.Name + "`", `"{#SERVICEDESC_$sun}`":`"" + $desc_val + "`", `"{#SERVICEDIR_$sun}`":`"" + $exe_dir + "`" }"
	
	if ($line -match $regex){
		Write-Host -NoNewline $line
		Write-Host ",";
	}
}

# Close the JSON message
write-host
write-host
write-host "`t ]";
write-host "}"
