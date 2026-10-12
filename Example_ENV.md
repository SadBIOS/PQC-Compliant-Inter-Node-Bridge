# Network Topology and Security Configuration

```text
    ┌────────────────────────────────────────────────────────────────────────┐
    │                                    WIN                                 │
    │                 Windows 11 Pro (OpenSSH_for_Windows_10.0p2)            │
    │                               LibreSSL 4.2.0                           │
    └────────────────────────────┬──────────────────┬────────────────────────┘
                                 │                  │
      KEX: mlkem768x25519-sha256 │                  │ KEX: mlkem768x25519-sha256
             Pubkey: ssh-ed25519 │                  │ Pubkey: ssh-ed25519
            Hostkey: ssh-ed25519 │                  │ Hostkey: ssh-ed25519
                                 │                  │
                                 v                  v
                 ┌──────────────────────┐    ┌──────────────────────┐
                 │        NODE A        │    │        NODE B        │
                 │    Debian (vm1)      │◄──►│     Debian (vm2)     │
                 │    OpenSSH_10.6p1    │    │    OpenSSH_10.6p1    │
                 │    OpenSSL 4.0.3     │    │    OpenSSL 4.0.3     │
                 └──────────────────────┘    └──────────────────────┘
                                    \          /
                                     \        /
                      KEX: mlkem768x25519-sha256 (Post-Quantum)
                      Pubkey:  ssh-mldsa44-ed25519 (Hybrid ML-DSA)
                      Hostkey: ssh-mldsa44-ed25519 (Hybrid ML-DSA)

```

<br>

# Connection Specifications

| Connection Link | Key Exchange (KEX) | Public Key Algorithm | Host Key Algorithm |
| --- | --- | --- | --- |
| **WIN <--> NODE A/B** | `mlkem768x25519-sha256` | `ssh-ed25519` | `ssh-ed25519` |
| **NODE A <--> NODE B** | `mlkem768x25519-sha256` | `ssh-mldsa44-ed25519` | `ssh-mldsa44-ed25519` |


> [!CAUTION]
> Both **Node A** and **Node B** have passphrase-less SSH keys as this is easier for machine to machine communication for scripts.
>
> **THIS IS NOT RECOMMENDED FOR MACHINES THAT REQUIRE HUMAN INTERACTION**

<br>

# Setting Up Node A

> [!NOTE]
> If using `scp` to move keys back and forth is recommended to wipe `known_hosts` and `known_hosts.old` at the end
> 
> Who recommended this? Me. Why? Because I want to.

Generating SSH Key-Pair
```bash
ssh-keygen -t mldsa44-ed25519 -f ~/.ssh/id_mldsa44_ed25519 -N "" -C "Node A's Quantum Safe SSH Key, No Passphrase"
```

<br>

Generating Host Key
```bash
sudo ssh-keygen -t mldsa44-ed25519 -f /etc/ssh/ssh_host_mldsa44_ed25519_key -N "" -C "Node A's Quantum Safe Host Key, No Passphrase"
```

<br>

Copy the Public Key to Node B

```bash
scp ~/.ssh/id_mldsa44_ed25519.pub username@<NODE_B_IP>:/home/username/nodeA.pub
```

Append it to `authorized_keys`

```bash
ssh username@<NODE_B_IP> "cat /home/username/nodeA.pub >> ~/.ssh/authorized_keys && rm /home/username/nodeA.pub"
```

<br>

Bypassing First Time Signature Message

```bash
ssh-keyscan -t mldsa44-ed25519 <NODE_B_IP> >> ~/.ssh/known_hosts
```

<br>

Connect from Node A to B 
```bash
ssh -i ~/.ssh/id_mldsa44_ed25519 username@<NODE_B_IP>
```

<br>

Automating Node to Node connection by editing `~/.ssh/config`, set the permission `chmod -v 600 ~/.ssh/config`

After this connecting from Node A to B is `ssh nodeb`

```txt
Host nodea
    HostName <NODE_B_IP>
    User username
    IdentityFile ~/.ssh/id_mldsa44_ed25519
```

<br>

Finally test and restart the `ssh` service
```bash
sudo sshd -t
```
```bash
sudo systemctl restart ssh
```

<br>
