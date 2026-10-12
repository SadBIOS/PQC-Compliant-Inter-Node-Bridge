
# Network Topology and Security Configuration

```text
    ┌────────────────────────────────────────────────────────────────────────┐
    │                                  WIN                                   │
    │            Windows 11 Pro (OpenSSH_for_Windows_10.0p2)                 │
    │                         LibreSSL 4.2.0                                 │
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
                 │   OpenSSH_10.6p1     │    │   OpenSSH_10.6p1     │
                 │   OpenSSL 4.0.3      │    │   OpenSSL 4.0.3      │
                 └──────────────────────┘    └──────────────────────┘
                                    \          /
                                     \        /
                      KEX: mlkem768x25519-sha256 (Post-Quantum)
                      Pubkey:  ssh-mldsa44-ed25519 (Hybrid ML-DSA)
                      Hostkey: ssh-mldsa44-ed25519 (Hybrid ML-DSA)

```

# Connection Specifications

| Connection Link | Key Exchange (KEX) | Public Key Algorithm | Host Key Algorithm |
| --- | --- | --- | --- |
| **WIN <--> NODE A/B** | `mlkem768x25519-sha256` | `ssh-ed25519` | `ssh-ed25519` |
| **NODE A <--> NODE B** | `mlkem768x25519-sha256` | `ssh-mldsa44-ed25519` | `ssh-mldsa44-ed25519` |


