#!/bin/bash

if [[ $# -eq 0 ]]; then
    exit 0
fi

sudo -v || {
    printf "\n\e[31mAuthentication failed\e[0m\n" >&2
    exit 1
}

SCRIPT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME="$SCRIPT_ROOT/dep_fetch.sh"
PKGLIST="$SCRIPT_ROOT/pkglist.txt"
PKG_ARCH="$SCRIPT_ROOT/end2end-PQC_dependencies.tar.gz"

HASHLIB="$SCRIPT_ROOT/hashes.txt"

OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-4.0.3/openssl-4.0.3.tar.gz"
OPENSSH_URL="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz"

OPENSSL_SOURCE_CODE=$(basename "$OPENSSL_URL")
OPENSSH_SOURCE_CODE=$(basename "$OPENSSH_URL")

DEPS=(
    build-essential
    zlib1g-dev
    libssl-dev
    libpam0g-dev
    libselinux1-dev
    wget
    micro
    perl
    tar
    pkg-config
    ca-certificates
    rsync
    screen
)


function conn_stat() {
    ping -c 1 -W 2 1.1.1.1 &>/dev/null || ping -c 1 -W 2 8.8.8.8 &>/dev/null
}

function online() {
    if ! conn_stat; then
        echo -e "\033[31mCannot resolve dependencies on an offline machine\033[0m" >&2
        exit 1
    fi

    sudo apt update && sudo apt install -y "${DEPS[@]}"
}

function makepkg_cache() {
    if conn_stat; then
        if [[ -f "$PKGLIST" || -f "$PKG_ARCH" ]]; then
            rm -vrf "$PKGLIST"
            rm -vrf "$PKG_ARCH"
        fi

        printf '%s\n' "${DEPS[@]}" > "$PKGLIST"

        "$RUNTIME" --gen-pkglist "$PKGLIST"
        
        if [[ -f "$PKGLIST" ]]; then
            rm -vrf "$PKGLIST"
        fi

        find $SCRIPT_ROOT -maxdepth 1 -type f -name 'depsys-custpkg-*.tar.gz' -exec mv -v {} "$PKG_ARCH" \;
    fi
}

function offline() {
    if [[ ! -f "$PKG_ARCH" ]]; then
        if ! conn_stat; then
            echo -e "\033[31mNo Dependency archive was found\033[0m" >&2
            echo -e "\033[31mAdditionally the machine is offline thus dependency archive creation is not possible\033[0m" >&2
            exit 1
        else
            makepkg_cache
        fi
    else
        "$RUNTIME" --dgst-pkglist "$PKG_ARCH"
    fi
}

function check_deps() {
    for pkg in "${DEPS[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            return 1
        fi
    done
    return 0
}


function data_integrity() {
    case "$1" in
        calc)
            printf '%s,%s\n' "$2" "$(sha512sum -- "$2" | cut -d ' ' -f 1)" >> "$HASHLIB" || return 1
            return 0
        ;;
        
        match)
            [[ -f "$2" && -f "$HASHLIB" ]] || return 1
            [[ "$(sha512sum -- "$2" | cut -d ' ' -f 1)" == "$(awk -F ',' -v filename="$(basename "$2")" '$1 == filename { hash = $2 } END { print hash }' "$HASHLIB")" ]]
            return $?
        ;;
    esac
}

function check_version() {
    if [[ "$1" == *openssh* ]]; then
        TARGET_VERSION=$(echo "$1" | sed -E 's/openssh-(.*)\.tar\.gz/\1/')
        CURRENT_VERSION=$(ssh -V 2>&1 | head -n1 | cut -d' ' -f1 | cut -d'_' -f2)
        if [ "$(printf '%s\n' "$CURRENT_VERSION" "$TARGET_VERSION" | sort -V | head -n1)" = "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$TARGET_VERSION" ]; then
            echo -e "\033[0;32mEligible Receiver 97\033[0m"
            return 0
        else
            echo -e "\033[0;31mA More Recent Version of OpenSSH is Already Installed. Exiting.\033[0m"
            return 1
        fi
    elif [[ "$1" == *openssl* ]]; then
        TARGET_VERSION=$(echo "$1" | sed -E 's/openssl-(.*)\.tar\.gz/\1/')
        CURRENT_VERSION=$(openssl version | awk '{print $2}')
        if [ "$(printf '%s\n' "$CURRENT_VERSION" "$TARGET_VERSION" | sort -V | head -n1)" = "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$TARGET_VERSION" ]; then
            echo -e "\033[0;32mEligible Receiver 97\033[0m"
            return 0
        else
            echo -e "\033[0;31mA More Recent Version of OpenSSH is Already Installed. Exiting.\033[0m"
            return 1
        fi
    fi
}

function build_openssl() {
    if data_integrity match "$OPENSSL_SOURCE_CODE"; then
        echo -e "\033[32mLocal OpenSSL Checksum Passed.\033[0m"
    else
        read -r -p "$OPENSSL_SOURCE_CODE Does Not Exist or Corrupted. Want to Re-Download it? [y/n] " answer
        case "$answer" in
            y|Y)
                if conn_stat; then
                    if wget -P "$SCRIPT_ROOT" -O "$OPENSSL_SOURCE_CODE" "$OPENSSL_URL"; then
                        data_integrity calc "$OPENSSL_SOURCE_CODE"
                        echo -e "\033[32mOpenSSL downloaded successfully.\033[0m"
                    else
                        echo "OpenSSL download failed."
                        exit 0
                    fi 
                else
                    echo -e "\033[31Machine is offline.\033[0m"
                    exit 1
                fi
            ;;
            
            n|N)
                echo "Not Downloading $OPENSSL_SOURCE_CODE"
                exit 1
            ;;
        esac
    fi

    if check_version "$OPENSSL_SOURCE_CODE"; then
        tar -xzvf "$OPENSSL_SOURCE_CODE"
        cd "${OPENSSL_SOURCE_CODE%.tar.gz}"
        ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
        make -j $(nproc)
        sudo make install
        echo "/usr/local/ssl/lib64" | sudo tee /etc/ld.so.conf.d/openssl-4.0.conf
        sudo ldconfig
        sudo mv /usr/bin/openssl /usr/bin/openssl.bak
        sudo ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
        cd ..
    fi
}

function build_openssh() {
    if data_integrity match "$OPENSSH_SOURCE_CODE"; then
        echo -e "\033[32mLocal OpenSSH Checksum Passed.\033[0m"
    else
        read -r -p "$OPENSSH_SOURCE_CODE Does Not Exist or Corrupted. Want to Re-Download it? [y/n] " answer
        case "$answer" in
            y|Y)
                if conn_stat; then
                    if wget -P "$SCRIPT_ROOT" -O "$OPENSSH_SOURCE_CODE" "$OPENSSH_URL"; then
                        data_integrity calc "$OPENSSH_SOURCE_CODE"
                        echo -e "\033[32mOpenSSH downloaded successfully.\033[0m"
                    else
                        echo "OpenSSH download failed."
                        exit 0
                    fi
                else
                    echo -e "\033[31Machine is offline.\033[0m"
                    exit 1
                fi
            ;;
            
            n|N)
                echo "Not Downloading $OPENSSH_SOURCE_CODE"
                exit 1
            ;;
        esac
    fi
    
    if check_version "$OPENSSH_SOURCE_CODE"; then
        tar -xzvf "$OPENSSH_SOURCE_CODE"
        cd "${OPENSSH_SOURCE_CODE%.tar.gz}"
        ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-ssl-dir=/usr/local/ssl LDFLAGS="-Wl,-rpath,/usr/local/ssl/lib64"
        make -j $(nproc)
        ./ssh -V
        sudo make install
        sudo systemctl restart ssh
        cd ..
    fi
}

function build_and_install() {
    if check_deps; then
        echo -e "\033[32mAll dependencies are installed.\033[0m"
        build_openssl
        build_openssh
        exit 0
    else
        echo -e "\033[31mSome dependencies are missing.\033[0m"
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ins-deps-onln)
            online
            exit 0
        ;;

        --fetch-dep-packs)
            makepkg_cache
            exit 0
        ;;

        --inst-deps-ofln)
            offline
            exit 0
        ;;

        --build-all)
            build_and_install
            exit 0
        ;;
    esac
done
