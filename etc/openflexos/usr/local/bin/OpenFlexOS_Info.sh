#!/usr/bin/env bash

STATE_FILE="$HOME/.ip_script_index"
ICON=" "

functions=(
  get_router_ip
  get_local_ip
  get_public_ip
  get_hostname
  get_uptime
)
get_router_ip() {
    echo "$ICON Router IP: $(ip route get 1.1.1.1 | awk '/via/ {print $3; exit}')"
}
# Print the local IPv4 address, appending (s) for a locally configured static IP.
get_local_ip() {
    local route iface local_ip connection method network_file
    route=$(ip -4 route get 1.1.1.1 2>/dev/null) || route=""
    iface=$(awk '{for (i=1; i<=NF; i++) if ($i=="dev") {print $(i+1); exit}}' <<< "$route")
    local_ip=$(awk '{for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}' <<< "$route")

    if [[ -n "$iface" && -n "$local_ip" ]]; then
        # NetworkManager: 'manual' means the IPv4 address is configured statically.
        if command -v nmcli >/dev/null 2>&1; then
            connection=$(nmcli -g GENERAL.CONNECTION device show "$iface" 2>/dev/null | head -n 1)
            if [[ -n "$connection" && "$connection" != "--" ]]; then
                method=$(nmcli -g ipv4.method connection show "$connection" 2>/dev/null)
                if [[ "$method" == "manual" ]]; then
                    local_ip+="(s)"
                fi
                echo "$ICON Local IP: $local_ip"
                return
            fi
        fi

        # systemd-networkd: inspect the configuration file in use for this interface.
        if command -v networkctl >/dev/null 2>&1; then
            network_file=$(networkctl status "$iface" --no-pager 2>/dev/null | sed -n 's/^[[:space:]]*Network File: //p' | head -n 1)
            if [[ -f "$network_file" ]]; then
                # Only mark static if this exact address is declared in the config.
                if awk -F= -v ip="$local_ip" '
                    /^[[:space:]]*Address[[:space:]]*=/ {
                        value=$2; gsub(/[[:space:]]/, "", value)
                        split(value, parts, "/")
                        if (parts[1] == ip) found=1
                    }
                    END {exit !found}
                ' "$network_file"; then
                    local_ip+="(s)"
                fi
            fi
        fi
    fi
    echo "$ICON Local IP: $local_ip"
}

get_public_ip() {
    echo "$ICON Public IP: $(curl -4s icanhazip.com)"
}

get_hostname() {
    echo "$ICON Hostname: $(cat /etc/hostname)"
}

get_uptime(){
    # Read uptime in seconds
    uptime_seconds=$(cut -d' ' -f1 /proc/uptime)
    uptime_seconds=${uptime_seconds%.*}

    days=$(( uptime_seconds / 86400 ))
    hours=$(( (uptime_seconds % 86400) / 3600 ))
    minutes=$(( (uptime_seconds % 3600) / 60 ))

    if (( uptime_seconds < 3600 )); then
        # Under 1 hour → show minutes only
        echo "$ICON Uptime: ${minutes}m"
    elif (( uptime_seconds < 86400 )); then
        # Under 1 day → show hours:minutes
        echo "$ICON Uptime: ${hours}h:${minutes}m"
    else
        # 1 day+ → show days:hours:minutes
        echo "$ICON Uptime: ${days}d:${hours}h:${minutes}m"
    fi
}

index=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
max=$(( ${#functions[@]} - 1 ))

while getopts "nprluoh" opt; do
  case "$opt" in
    n)
      ((index++))
      (( index > max )) && index=0
      ;;
    p)
      ((index--))
      (( index < 0 )) && index=$max
      ;;
    r)
    get_router_ip | awk '{print $4}'
    exit 0
      ;;
    l)
    get_local_ip | awk '{print $4}'
    exit 0
      ;;
    u)
    get_public_ip | awk '{print $4}'
    exit 0
      ;;
    o)
    get_hostname | awk '{print $3}'
    exit 0
      ;;
    h)
echo "Get Baisc Info
Usage: OpenFlexOS_Info.sh [-n | -p | -r | -l | -u | -o | -h]

-n              Rotate Forwards Between Options
-p              Rotate Backwards Between Options
-r              Shows Router/Gateway IP Address
-l              Shows Local/Private IP Address
-u              Shows Public IP Address
-o              Shows Hostname
-h              Show this help message"
    exit 0
      ;;
  esac
done

"${functions[index]}"
echo "$index" > "$STATE_FILE"
