$newIP = "8.8.8.8" #Google DNS-Server


$netAdapter = Get-NetAdapter | Where-Object { $_.Name -eq "Ethernet" }

if ($null -eq $netAdapter) {
    Write-Host "No network adapter found. Check adapternamen."
}
else {
    $netAdapter | Set-DnsClientServerAddress -ServerAddresses $newIP

    if ($?) {
        Write-Host "Set new DNS serveraddress to $newIP."
    }
    else {
        Write-Host "Error at DNS serveraddress changing!."
    }
}