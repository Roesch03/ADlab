#param(
#    $usersFile
#)

# Disable Internet first run wizard
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

# ---- Edit these variables for your own Use Case ---- #
$PASSWORD_FOR_USERS = "Password1"
Invoke-WebRequest "https://raw.githubusercontent.com/Roesch03/ADlab/main/Users.txt" -OutFile ./Users.txt
$USER_FIRST_LAST_LIST = Get-Content .\Users.txt
# ---------------------------------------------------- #

$password = ConvertTo-SecureString $PASSWORD_FOR_USERS -AsPlainText -Force
$OUs = $(foreach($line in Get-content .\Users.txt){$line.split("`t")[2]})|Sort-Object |Get-Unique
foreach($OU in $OUs){New-adorganizationalunit -Name $OU -ProtectedFromAccidentalDeletion $false}

foreach($n in $USER_FIRST_LAST_LIST){
    $first = $n.split("`t")[0]
    $last = $n.split("`t")[1]
    $userOU = $n.split("`t")[2]
    $username = "$($first.Substring(0,1))$($last)"
    Write-Host "Creating user in $($userOU): $($username)" -BackgroundColor Black -ForegroundColor Cyan

    New-AdUser -AccountPassword $password `
                -GivenName $first `
                -Surname $last `
                -DisplayName "$($first) $($last)" `
                -Name $username `
                -EmployeeID $username `
                -PasswordNeverExpires $true `
                -Department $userOU `
                -Path "ou=$($userOU),$(([ADSI]`"").distinguishedName)" `
                -Enabled $true
}

