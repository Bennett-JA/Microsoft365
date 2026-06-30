# PnP PowerShell Interactive Login Setup

## Overview

Following Microsoft's security improvements, administrators now need to register their own Entra ID applications to use with PnP PowerShell for interactive login.

## Registration Process

### Step 1: Register the Application

Run this command to register your application:

```powershell
Register-PnPEntraIDApp -ApplicationName "PnP Module App" -Tenant "Tenant ID" -Interactive
```

### Step 2: Authentication Prompt

After running the command, you will be prompted to:

1. **Authenticate with your credentials** - Enter your admin username and password
2. **Grant consent to the app** - You'll see a consent screen asking to approve permissions for the new application

### Step 3: Application Registration Complete

Once you complete the authentication and consent steps:

- The new application will be registered in Entra ID
- You'll receive output containing the Client ID (save this for connecting)
- If you don't see the output login to entra and find the application in app registrations
- A limited set of default permission scopes will be added automatically

### Step 4: Connect to PnP PowerShell

Use the Client ID from the registration output to connect:

To connect to the admin portal

```powershell
Connect-PnPOnline contoso.sharepoint.com -Interactive -ClientId "your-client-id-from-registration"
```
To connect to a specific site

```powershell
Connect-PnPOnline -Url "SITE URL" -Interactive -ClientId "CLIENT ID"
```

## What Happens During Registration

1. **Command execution** - PowerShell initiates the app registration process
2. **Browser opens** - You'll be redirected to Microsoft's authentication page
3. **Login required** - Enter your admin credentials
4. **Consent screen** - Approve the permissions the app is requesting
5. **Registration complete** - App is created in your Entra ID tenant

## Important Notes

- Replace `<app name>` with your desired application name
- Replace `<tenantname>` with your actual tenant name
