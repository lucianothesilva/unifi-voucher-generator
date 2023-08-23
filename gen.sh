#!/bin/bash

# Files needed
pwd=`pwd`
. $pwd/unifi-api.sh

# Generation settings
if [ -n "$1" ]; then
  time=$1 # Voucher time limit (minutes)
else
  time=60 # Voucher time limit (minutes)
fi
if [ -n "$2" ]; then
  amount=$2 # New vouchers to generate
else
  amount=10 # New vouchers to generate
fi

# HTML Settings
line1="Rede Voucher"
line2="1 - Leia o QRCode abaixo para conectar-se à rede Voucher"
line3="2 - Uma nova aba abrirá, utilize o código a seguir para acessar à internet:" 


# Generate vouchers
unifi_login
voucherID=`unifi_create_voucher $time $amount $note`
unifi_get_vouchers $voucherID > vouchers.tmp
unifi_logout

vouchers=`awk -F"[,:]" '{for(i=1;i<=NF;i++){if($i~/code\042/){print $(i+1)} } }' vouchers.tmp | sed 's/\"//g'`

# Build HTML
if [ -e vouchers.html ]; then
  echo "Removing old vouchers."
  rm vouchers.html
fi

echo '<html><head><link rel="stylesheet" href="style.css" /></head><body>' >> vouchers.html

for code in $vouchers
do
    line4=${code:0:5}" "${code:5:10}
    line3_modified=$(echo "$line3 <strong>$line4</strong>") 

    echo '<div class="voucher-card">' >> vouchers.html
    echo '<div class="voucher"><div class="line1">'$line1'</div><div class="line2">'$line2'</div><div class="line3">'$line3_modified'</div><img class="qrcode" src="qrcode.jpg" alt="QR Code"></div>' >> vouchers.html
    echo '</div>' >> vouchers.html
done

echo "</body></html>" >> vouchers.html


# Remove tmp
if [ -e vouchers.tmp ]; then
  echo "Removing vouchers tmp file."
  rm vouchers.tmp
fi
