build {
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    inline = [
      # Install Node.js and npm
      "Invoke-WebRequest -Uri https://nodejs.org/dist/v14.17.0/node-v14.17.0-x64.msi -OutFile nodejs.msi",
      "Start-Process msiexec.exe -ArgumentList '/i nodejs.msi /quiet /norestart' -NoNewWindow -Wait",
      "npm install -g npm@latest",

      # Install Maven
      "Invoke-WebRequest -Uri https://downloads.apache.org/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.zip -OutFile maven.zip",
      "Expand-Archive -Path maven.zip -DestinationPath C:\\maven",
      "$env:Path += ';C:\\maven\\apache-maven-3.8.1\\bin'",
      "[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)",

      # Install Java
      "Invoke-WebRequest -Uri https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.msi -OutFile java.msi",
      "Start-Process msiexec.exe -ArgumentList '/i java.msi /quiet /norestart' -NoNewWindow -Wait"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "5m"
  }
}