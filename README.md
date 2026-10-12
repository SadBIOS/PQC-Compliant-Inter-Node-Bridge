# PQC Compliant Point to Point Network Setup Utility

This repository is mainly designed to add custom/latest builds of **OpenSSH** and **OpenSSL™** on **Debian<sup>®</sup>** based machines. Since **Debian<sup>®</sup>** based operation systems stable thus they ship with more stable versions of these packages. The utilities and techniques discussed here allows set Quantum Safe **[(NIST Security Category 3)](https://postquantum.com/post-quantum/nist-pqc-security-categories/)** tunnels between machines. 
<br>
<div align="center">
  <h3 style="margin: 0; padding: 0;">The Alphabet Boys Can See Everything</h3>
  <p style="margin: 0; padding: 0;">Now they are coming for your mind</p>
</div>
<br>

> [!WARNING]
> A controlled "low security" i.e. non PQC compliant entrypoint has been introduced on purpose as unfortunately Microsoft Windows<sup>®</sup> does not feature a fully capable OpenSSH and LibreSSL build with our required features.
> 
> **AND YES THIS IS A SECURITY VULNERABILITY**
>
> Well what do you expect from **MicroSlop**


# Automatic Installation for Internet Connected Devices

Download the scripts and go the directory where the scripts are contained (this example will assume that they are placed in `$HOME` and it is empty) and run the following commands
```bash
chmod +x -v *.sh
```
This will activate the scripts once that is done just copy and paste the following commands. Please review the scripts before running this (this should be standard practice for any/all scripts from unknown sources).

<br>

Run the following commands to resolve compilation dependencies.
```bash
./setup.sh --ins-deps-onln
```
Once everything has been downloaded run the final command.
```bash
./setup.sh --build-all
```


# Automatic Installation for Airgapped Machines

This method can be used to deploy the required packages onto isolated networks. For ease of use place the scripts inside a directory so that all the downloaded files are in one location thus making it easy to distribute between devices.
```bash
./setup.sh --fetch-dep-packs
```
This will download all the required files inside the root directory of the script.

<br>

After copying/distributing the files among the nodes install dependencies.
```bash
./setup.sh --inst-deps-ofln
```

<br>

Finally install the packages (similarly as before).
```bash
./setup.sh --build-all
```


# Manual Installation

This method is recommended on interned dependent machines. Yes, if you want you can read the script and prepare the build system for transferring into airgapped nodes.

<br>

Install Dependencies
```bash
sudo apt install -y build-essential zlib1g-dev libssl-dev libpam0g-dev libselinux1-dev wget micro perl tar pkg-config ca-certificates rsync
```

