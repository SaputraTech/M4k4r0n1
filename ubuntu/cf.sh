#!/bin/bash

# Get current IP
MYIP=$(curl -s ipv4.icanhazip.com)

# Install dependencies
apt update && apt install -y jq curl

# Cloudflare credentials
DOMAIN="hapeey.shop"
CF_ID="egesam064@gmail.com"
CF_KEY="Z1poADbXOyDheuit-sOLndF7vBIHd8pvnMDu7LY"  # New API token

# Function to generate random subdomain
generate_subdomain() {
    echo "$(tr -dc a-z0-9 </dev/urandom | head -c5).${DOMAIN}"
}

# Function to check if subdomain exists
check_subdomain_exists() {
    local subdomain=$1
    local zone_id=$2
    RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${subdomain}" \
        -H "Authorization: Bearer ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r .result[0].id)
    [[ -n "$RECORD" ]]
}

# Get Zone ID
ZONE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "Authorization: Bearer ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

# Generate unique subdomain
while true; do
    sub=$(generate_subdomain)
    if ! check_subdomain_exists "$sub" "$ZONE"; then
        break
    fi
done

echo "Using subdomain: ${sub}"
echo "Updating DNS for ${sub}..."

# Update DNS record
IP=$(curl -s ipv4.icanhazip.com)
RECORD_ID=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
    -H "Authorization: Bearer ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${sub}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)

# Save subdomain information
echo "$sub" | tee /root/domain /root/scdomain /etc/xray/domain /etc/v2ray/domain /etc/xray/scdomain

echo "IP=${MYIP}" > /var/lib/kyt/ipvps.conf

echo "DNS update completed successfully."
exit 0
