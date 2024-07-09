build {
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    inline = [
      # Install Node.js and npm
      "Invoke-WebRequest -Uri https://nodejs.org/dist/v18.17.0/node-v18.17.0-x64.msi -OutFile nodejs.msi",
      "Start-Process msiexec.exe -ArgumentList '/i nodejs.msi /quiet /norestart' -NoNewWindow -Wait",
      # Ensure npm is available in the path
      "$env:Path += ';C:\\Program Files\\nodejs'",
      "[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)",
      # Update npm to the latest version
      "& 'C:\\Program Files\\nodejs\\npm.cmd' install -g npm@latest",
      
      # Install Maven
      "Invoke-WebRequest -Uri https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.zip -OutFile maven.zip",
      "Expand-Archive -Path maven.zip -DestinationPath C:\\maven",
      "$env:Path += ';C:\\maven\\apache-maven-3.8.1\\bin'",
      "[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)",
      
      # Install Java
      "Invoke-WebRequest -Uri https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.msi -OutFile java.msi",
      "Start-Process msiexec.exe -ArgumentList '/i java.msi /quiet /norestart' -NoNewWindow -Wait",
      # Ensure Java is available in the path
      "$env:Path += ';C:\\Program Files\\Java\\jdk-17\\bin'",
      "[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)"
    ]
  }

  # Run Sysprep to generalize the image
  provisioner "powershell" {
    inline = [
        "# If Guest Agent services are installed, make sure that they have started.",
        "foreach ($service in Get-Service -Name RdAgent, WindowsAzureTelemetryService, WindowsAzureGuestAgent -ErrorAction SilentlyContinue) { while ((Get-Service $service.Name).Status -ne 'Running') { Start-Sleep -s 5 } }",

        "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
        "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }

}