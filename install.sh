#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Run this script as root!"
    exit 1
fi

SYSCTL_FILE="/etc/sysctl.d/99-tcp-optimizer.conf"

function banner() {
    clear
    echo "========== TCP OPTIMIZER =========="
    echo "Persistent Kernel Network Tweaks"
    echo "=================================="
}

function apply_settings() {
    banner
    echo "Applying TCP optimizations..."

    cat <<EOF > $SYSCTL_FILE
# TIME_WAIT tuning
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10

# Port exhaustion prevention
net.ipv4.ip_local_port_range = 10000 65535

# Orphaned sockets
net.ipv4.tcp_max_orphans = 262144

# Keepalive tuning
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# SYN flood & backlog
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_syncookies = 1
EOF

    sysctl --system >/dev/null 2>&1

    echo ""
    echo "✔ TCP optimization applied & persisted"
    read -p "Press Enter to return to menu..."
    main_menu
}

function view_settings() {
    banner
    if [[ -f $SYSCTL_FILE ]]; then
        echo "Current persistent settings:"
        echo "----------------------------------"
        cat $SYSCTL_FILE
    else
        echo "No optimizer config found."
    fi
    echo ""
    read -p "Press Enter to return to menu..."
    main_menu
}

function reset_settings() {
    banner
    read -p "Are you sure you want to REMOVE all optimizer settings? [Y/N]: " confirm
    if [[ $confirm == [Yy]* ]]; then
        rm -f $SYSCTL_FILE
        sysctl --system >/dev/null 2>&1
        echo ""
        echo "✔ Optimizer settings removed"
    else
        echo "Cancelled."
    fi
    read -p "Press Enter to return to menu..."
    main_menu
}

function main_menu() {
    banner
    echo "1) Apply TCP Optimizations"
    echo "2) View Current Settings"
    echo "3) Remove / Reset Settings"
    echo "4) Exit"
    echo ""
    read -p "Select option: " choice

    case $choice in
        1) apply_settings ;;
        2) view_settings ;;
        3) reset_settings ;;
        4) exit 0 ;;
        *) main_menu ;;
    esac
}

main_menu
