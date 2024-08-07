Add-Type -AssemblyName System.Windows.Forms

function Show-ConnectorInputForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Enter Connector Details'
    $form.Size = New-Object System.Drawing.Size(400, 250)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Location = New-Object System.Drawing.Point(75, 150)
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cancelButton.Location = New-Object System.Drawing.Point(200, 150)
    $form.Controls.Add($cancelButton)

    $labelsAndTextboxes = @(
        @{label = 'Connector Name'; name = 'connectorName'; location = [System.Drawing.Point]::new(20, 20)}
    )

    $textboxes = @{}
    foreach ($item in $labelsAndTextboxes) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $item.label
        $label.Location = $item.location
        $form.Controls.Add($label)

        $textbox = New-Object System.Windows.Forms.TextBox
        $textbox.Name = $item.name
        $textbox.Location = [System.Drawing.Point]::new($item.location.X + 120, $item.location.Y)
        $textbox.Width = 200
        $form.Controls.Add($textbox)
        $textboxes[$item.name] = $textbox
    }

    # Add a label and textbox for the folder path
    $folderLabel = New-Object System.Windows.Forms.Label
    $folderLabel.Text = 'Selected Folder'
    $folderLabel.Location = New-Object System.Drawing.Point(20, 80)
    $form.Controls.Add($folderLabel)

    $folderTextbox = New-Object System.Windows.Forms.TextBox
    $folderTextbox.Name = 'selectedFolder'
    $folderTextbox.Location = New-Object System.Drawing.Point(140, 80)
    $folderTextbox.Width = 160
    $form.Controls.Add($folderTextbox)

    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Text = '...'
    $browseButton.Location = New-Object System.Drawing.Point(310, 80)
    $browseButton.Width = 30
    $form.Controls.Add($browseButton)

    $browseButton.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $folderTextbox.Text = $folderBrowser.SelectedPath
        }
    })

    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton

    $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{
            ConnectorName = $textboxes.connectorName.Text
            SelectedFolder = $folderTextbox.Text
        }
    } else {
        return $null
    }
}

$null = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("CreateTargetConnector", {
    $inputForm = Show-ConnectorInputForm
    if ($null -eq $inputForm) { return }

    $connectorName = $inputForm.ConnectorName
    $connectorType = "Target"
    $selectedFolder = $inputForm.SelectedFolder

    $repositoryUrl = 'https://api.github.com/repos/Tools4everBV/HelloID-Conn-Prov-Target-V2-Template/contents/target'
    $folderName = "HelloID-Conn-Prov-$connectorType-$connectorName".Trim().Replace(' ', '-')
    $folderPath = Join-Path -Path $selectedFolder -ChildPath $folderName
    $testPath = Join-Path -Path $folderPath -ChildPath 'test'
    $groupsPermissionsPath = Join-Path -Path $folderPath -ChildPath 'permissions/groups'
    $groupsResourcesPath = Join-Path -Path $folderPath -ChildPath 'resources/groups'

    New-Item -ItemType Directory -Path $folderPath -Force
    New-Item -ItemType Directory -Path $testPath -Force
    New-Item -ItemType Directory -Path $groupsPermissionsPath -Force
    New-Item -ItemType Directory -Path $groupsResourcesPath -Force

    $allContent = Invoke-RestMethod -Uri $repositoryUrl

    foreach ($file in $allContent) {
        if ($file.type -eq 'file') {
            $fileUrl = $file.download_url
            $fileContent = Invoke-RestMethod -Uri $fileUrl
            $filePath = Join-Path -Path $folderPath -ChildPath $file.name

            if ($file.name -eq 'CHANGELOG.md') {
                $fileContent = $fileContent -replace '{currentDate}', (Get-Date -Format 'dd-MM-yyyy')
                $fileContent = $fileContent -replace '{connectorName}', $connectorName
            } elseif ($file.name -eq '.gitignore') {
                $fileContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($file.content))
            } else {
                $fileContent = $fileContent -replace '{connectorName}', $connectorName
            }

            Set-Content -Path $filePath -Value $fileContent -Force
        }
    }

    $testContent = Invoke-RestMethod -Uri "$repositoryUrl/test"
    foreach ($file in $testContent) {
        $fileUrl = $file.download_url
        $fileContent = Invoke-RestMethod -Uri $fileUrl
        $filePath = Join-Path -Path $testPath -ChildPath $file.name

        Set-Content -Path $filePath -Value $fileContent -Force
    }

    $permissionsContent = Invoke-RestMethod -Uri "$repositoryUrl/permissions/groups"
    foreach ($file in $permissionsContent) {
        $fileUrl = $file.download_url
        $fileContent = Invoke-RestMethod -Uri $fileUrl
        $filePath = Join-Path -Path $groupsPermissionsPath -ChildPath $file.name

        Set-Content -Path $filePath -Value $fileContent -Force
    }

    $resourcesContent = Invoke-RestMethod -Uri "$repositoryUrl/resources/groups"
    foreach ($file in $resourcesContent) {
        $fileUrl = $file.download_url
        $fileContent = Invoke-RestMethod -Uri $fileUrl
        $filePath = Join-Path -Path $groupsResourcesPath -ChildPath $file.name

        Set-Content -Path $filePath -Value $fileContent -Force
    }

    explorer $folderPath

    [System.Windows.MessageBox]::Show("Created new PowerShell $connectorType connector: $connectorName")
}, "Ctrl+Alt+C")
