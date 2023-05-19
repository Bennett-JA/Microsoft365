Connect-Graph -Scopes User.Read.All, Organization.Read.All

# Import CSV with UPNs
$UserList = Import-Csv -Path "C:\Users\AMC\OneDrive\Tech\Powershell\AAD\Users\MSG\UserUPNs.csv"

# Add SkuID
# locate SKUID using Get-MgSubscribedSku
$BusinessStandardSkuID = "c42b9cae-ea4f-4ab7-9717-81576235ccac"
$powerautomateSkuID = "f30db892-07e9-47e9-837c-80727f46fd3d"


# Prepare the license modification
$LicenseMod = @{
    "addLicenses" = @( @{
        "disabledPlans" = @();
        "skuId" = $BusinessStandardSkuID
    });
    "removeLicenses" = @($powerautomateSkuID);
}



# Loop through each user in the CSV file and apply the license modification
foreach ($User in $UserList) {
    Set-MgUserLicense -UserId $User.UPN -BodyParameter $LicenseMod
}
