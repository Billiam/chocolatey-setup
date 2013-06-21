$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function Install-NeededFor {
param([string]$packageName = '')
  if ($packageName -eq '') {return $false}

  $yes = '6'
  $no = '7'
  $msgBoxTimeout='-1'

  $answer = $msgBoxTimeout
  try {
    $timeout = 10
    $question = "Do you need to install $($packageName)? Defaults to 'Yes' after $timeout seconds"
    $msgBox = New-Object -ComObject WScript.Shell
    $answer = $msgBox.Popup($question, $timeout, "Install $packageName", 0x4)
  }
  catch {
  }

  if ($answer -eq $yes -or $answer -eq $msgBoxTimeout) {
    write-host 'returning true'
    return $true
  }
  return $false
}

function Install-Pack ($file) {
  Get-Content $file | where {$_} | Foreach-Object { cinstm $_ }
}

$installChocolatey = Install-NeededFor 'chocolatey'
$installRuby = Install-NeededFor 'ruby / ruby devkit'
$installHome = Install-NeededFor 'home packages'

#install chocolatey
if ($installChocolatey) {
  iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall')) 
}

# ruby.devkit, and ruby if they are missing
if ($installRuby) {
  #cinstm ruby #devkit install will automatically install ruby
  cinstm ruby.devkit

  #perform ruby updates and get gems
  gem update --system
  gem install rake
  gem install bundler
}


Install-Pack $scriptPath\packages\main.txt

if ($installHome) {
  Install-Pack $scriptPath\packages\home.txt
}