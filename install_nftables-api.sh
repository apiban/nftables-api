#!/bin/bash
#-- install script for nftables-api

#-- pgpx.io
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo " ppppp   ppppppppp      ggggggggg   ggggg"
echo " p::::ppp:::::::::p    g:::::::::ggg::::g"
echo " p:::::::::::::::::p  g:::::::::::::::::g"
echo " pp::::::ppppp::::::pg::::::ggggg::::::gg"
echo "  p:::::p     p:::::pg:::::g     g:::::g "
echo "  p:::::p     p:::::pg:::::g     g:::::g "
echo "  p:::::p     p:::::pg:::::g     g:::::g "
echo "  p:::::p    p::::::pg::::::g    g:::::g "
echo "  p:::::ppppp:::::::pg:::::::ggggg:::::g "
echo "  p::::::::::::::::p  g::::::::::::::::g "
echo "  p::::::::::::::pp    gg::::::::::::::g "
echo "  p::::::pppppppp        gggggggg::::::g "
echo "  p:::::p                        g:::::g "
echo "  p:::::p            gggggg      g:::::g "
echo " p:::::::p           g:::::gg   gg:::::g "
echo " p:::::::p            g::::::ggg:::::::g "
echo " p:::::::p             gg:::::::::::::g  "
echo " ppppppppp               ggg::::::ggg    "
echo "                            gggggg       "
echo ""
echo ""
echo ""
echo " need support? https://palner.com"
echo ""
echo " Copyright (C) 2025 Fred Posner"
echo ""
echo " Permission is hereby granted, free of charge, to any person obtaining a copy"
echo " of this software and associated documentation files (the \"Software\"), to deal"
echo " in the Software without restriction, including without limitation the rights"
echo " to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
echo " copies of the Software, and to permit persons to whom the Software is"
echo " furnished to do so, subject to the following conditions:"
echo " "
echo " The above copyright notice and this permission notice shall be included in all"
echo " copies or substantial portions of the Software."
echo " "
echo " THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
echo " IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
echo " FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
echo " AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
echo " LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
echo " OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
echo " SOFTWARE."
echo ""

#-- download nftables-api
echo ""
echo " -> downloading nftables-api"
mkdir /usr/local/src/nftables-api
cd /usr/local/src/nftables-api
wget https://github.com/apiban/nftables-api/raw/1.0/nftables-api &>/dev/null
if [ "$?" -eq "0" ]
then
  echo "  -o downloaded"
else
  echo "  -x download FAILED!!"
  exit 1
fi

#-- make local folder and service
echo ""
echo " -> making run directory and service"
mkdir /usr/local/nftables-api
cp /usr/local/src/nftables-api/nftables-api /usr/local/nftables-api/nftables-api
chmod 755 /usr/local/nftables-api/nftables-api
cat > /lib/systemd/system/nftables-api.service << EOT
[Unit]
Description=nftables-api

[Service]
Type=simple
Restart=always
RestartSec=5s
ExecStart=/usr/local/nftables-api/nftables-api

[Install]
WantedBy=multi-user.target
EOT

#-- log rotate
echo " -> set up log rotate"
cat > /etc/logrotate.d/nftables-api << EOF
/var/log/nftables-api.log {
        daily
        copytruncate
        rotate 12
        compress
}
EOF

#-- reload / start service
echo " -> start service"
systemctl daemon-reload &>/dev/null
systemctl enable nftables-api &>/dev/null
systemctl start nftables-api &>/dev/null
