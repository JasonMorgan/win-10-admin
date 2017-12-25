#
# Cookbook:: win-10-admin
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

reboot 'now' do
  action :nothing
end

recipes = [
  'chocolatey::default',
]
recipes.each do |recipe|
  include_recipe recipe
end

node['win-10-admin']['packages'].each do |pkg|
  chocolatey_package pkg
end

powershell_script 'LinuxSubsystem' do
  code <<-EOH
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  EOH
  notifies :reboot_now, 'reboot[now]', :delayed
  not_if 'if (Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux  -Online) {$true}'
end

env 'path' do
  value "#{ENV['ProgramFiles']}\\git\\usr\\bin"
  action :modify
  delim ';'
end

env 'path' do
  value "'#{ENV['ProgramFiles(x86)']}\\Microsoft VS Code'"
  action :modify
  delim ';'
end

powershell_script 'mkdir' do
  code 'if (! (test-path C:\tools\cmder\vendor\conemu-maximus5\) ) { mkdir C:\tools\cmder\vendor\conemu-maximus5 }'
  not_if 'test-path C:\tools\cmder\vendor\conemu-maximus5'
end

cookbook_file 'C:\tools\cmder\vendor\conemu-maximus5\ConEmu.xml' do
  source 'ConEmu.xml'
  not_if 'test-path C:\tools\cmder\vendor\conemu-maximus5\ConEmu.xml'
end
