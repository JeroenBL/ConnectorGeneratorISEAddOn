# ConnectorGeneratorISEAddOn

## Table of contents

- [ConnectorGeneratorISEAddOn](#connectorgeneratoriseaddon)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Using the _ConnectorGeneratorISEAddOn_](#using-the-connectorgeneratoriseaddon)
    - [Installation](#installation)
    - [Create a new connector](#create-a-new-connector)

## Introduction

Hi 👋

If you're looking to create a new target connector for HelloID provisioning and don't know where to start, you're in the right place.

This _ConnectorGeneratorISEAddOn_ for the PowerShell ISE is the perfect starting point for building out your new connector, with all the essential resources you'll need to get started.

If you're a new to the templates and the _ConnectorGeneratorISEAddOn_ refer to the [QuickStart](https://jeroenbl.github.io/helloid/templates-quickStart/) to help you get started.

## Using the _ConnectorGeneratorISEAddOn_

### Installation

1. Open the _ISE_.

2. Create a new _Windows PowerShell ISE_ profile by executing the code pasted below:

```powershell
if (!(Test-Path -Path $PROFILE ))
{ New-Item -Type File -Path $PROFILE -Force }
```

3. Download (or copy) the contents of the `ConnectorGeneratorISEAddOn.ps1` file and add them to your Windows PowerShell ISE profile located in: `C:\Users\{username}\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1`

> [!NOTE]
> If you are using _OneDrive_, this file may be located in your _OneDrive_ in the `Documents` folder.

### Create a new connector

1. Open the `AddOns` menu and click: `CreateTargetConnector`.
2. Specify a name for the connector.
3. Browse to the folder where you want the new files to be created and press `enter`.
