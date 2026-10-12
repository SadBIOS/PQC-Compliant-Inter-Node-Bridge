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

> [!CAUTION]
> Replacing the core system OpenSSL™ (`/usr/bin/openssl`) on Linux distributions can sometimes break package managers or system tools that rely on the specific version provided by your OS vendor.

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

<br>

Download OpenSSH and OpenSSL™ Source code
```bash
wget https://github.com/openssl/openssl/releases/download/openssl-4.0.3/openssl-4.0.3.tar.gz; wget https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz
```

<br>

> [!WARNING]
> When compiling OpenSSH with a custom version of OpenSSL™ (instead of using the system's default) OpenSSL™ must be built first because OpenSSH has a direct and hard dependency on development files from OpenSSL™ during its build process.

## Building OpenSSL™

Extract the downloaded OpenSSL™ source code archive
```bash
tar -xzvf openssl-4.0.3.tar.gz; cd openssl-4.0.3
```

<br>

Inside the extracted directory run
```bash
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
```

<br>

Once configured compile
```bash
make -j $(nproc)
```

After compilation, copy compiled libraries, binaries and header files to `/usr/local/ssl`
```bash
sudo make install
```

<br>

Test the current build
```bash
LD_LIBRARY_PATH="$PWD" ./apps/openssl version
```

If everything seems alright add new OpenSSL™ library path to systems dynamic linker configuration
```bash
echo "/usr/local/ssl/lib64" | sudo tee /etc/ld.so.conf.d/openssl-4.0.conf
```

Refresh the system's shared library cache
```bash
sudo ldconfig -v
```

<br>
