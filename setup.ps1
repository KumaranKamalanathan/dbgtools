#########################################################################################################################
#  Author: Kumaran Kamalanathan                                                                                         #
#  Email:  kumaranconnect@hotmail.com                                                                                   #
#  The setup file configures windbg as a postmortem debugger and add's registry entries to enable windbg to open crash  #
#  dump files. Please be advised the file will make registry eidts.                                                     #
#                                                                                                                       #
#                                                                                                                       #
#                                                                                                                       #
#                                                                                                                       #
#########################################################################################################################


$current_dir = Get-Location 
$is32bit = $false;
$os_arch = Get-WmiObject Win32_OperatingSystem

if($os_arch.OSArchitecture.Contains("32"))
{
    $is32bit = $true;
}

#Directory Path for Symbols and SymCache, If required change path to desired location 
$sym_dir_path = $current_dir+"\Sym"
$symcache_dir_path = $current_dir+"\SymCache"

#windbg.exe relative path for 32 and 64 bit
$windbg_x86_path = $current_dir.Path + "\x86\windbg.exe"
$windbg_x64_path = $current_dir.Path + "\x64\windbg.exe"

#Symbol path location will be used to download symbols from microsoft symbols server by windbg 
$symbol_path = "SRV*"+$sym_dir_path+"*http://msdl.microsoft.com/download/symbols"


#Create dir for Symbols and SymCache
mkdir $sym_dir_path
mkdir $symcache_dir_path

#add psdrive to point to HKEY_CLASSES_ROOT
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

#add environment variables for SYMBOL and SymCache
$env:_NT_SYMBOL_PATH=$symbol_path
$env:_NT_SYMCACHE_PATH = $symcache_dir_path



if($is32bit)
{
#Install windbg x86 as default post-mortem debugger 
Start-Process -FilePath $windbg_x86_path -ArgumentList "-IA"
}
else
{
#Install windbg x64 as default post-mortem debugger 
Start-Process -FilePath $windbg_x64_path -ArgumentList "-IA"

#add registry path for x86 windbg
New-Item -Path HKCR:\WinDbg.DumpFile.1\shell\Open_x86
New-Item -Path HKCR:\WinDbg.DumpFile.1\shell\Open_x86\command

#New-ItemProperty -Path HKCR:\.dmp -PropertyType -Name "(Default)" String -Value "WinDbg.DumpFile.1"
#New-ItemProperty -Path HKCR:\.hdmp -PropertyType -Name "(Default)" String -Value "WinDbg.DumpFile.1"
#New-ItemProperty -Path HKCR:\.mdmp -PropertyType -Name "(Default)" String -Value "WinDbg.DumpFile.1"
#New-ItemProperty -Path HKCR:\.cab -PropertyType -Name "(Default)" String -Value "WinDbg.DumpFile.1"

#Key to allow right click on the .dmp file and choose to open with x86 or x64 windbg 
New-ItemProperty -Path HKCR:\WinDbg.DumpFile.1\shell\Open -Name "(Default)" -PropertyType String -Value "Openx&64"
New-ItemProperty -Path HKCR:\WinDbg.DumpFile.1\shell\Open_x86 -Name "(Default)" -PropertyType String -Value "Openx&86"

#Relative windbg.exe path for 32 and 64 bit 
New-ItemProperty -Path HKCR:\WinDbg.DumpFile.1\shell\Open\command -Name "(Default)" -PropertyType String -Value $windbg_x64_path + " -z %1" 
New-ItemProperty -Path HKCR:\WinDbg.DumpFile.1\shell\Open_x86\command -Name "(Default)" -PropertyType String -Value $windbg_x86_path " -z %1"

}


