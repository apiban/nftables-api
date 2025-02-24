# nftables-api

Very simple API for managing local nftables chain: `APIBANLOCAL`

Simple `GET` actions of add, remove, and flush (see [API usage](#API-usage) for more).

## Contents

* [Super Lazy Install](#super-lazy-install)
* [Usage](#usage)
  * [Default Settings](#default-settings)
  * [Example with flags](#example-with-flags)
* [Running as a Service (example)](#running-as-a-service-example)
* [Kamailio Example](#kamailio-example)
* **[API Usage](#api-usage)**
  * [Add/Block IP](#addblock-ip)
  * [Remove/Unblock IP](#removeunblock-ip)
  * [Flush APIBANLOCAL set](#flush-apibanlocal-set)
* [License / Warranty](#license--warranty)

## Super Lazy Install

Please at least look at the script before blindly running it on your system.

`curl -sSL https://raw.githubusercontent.com/apiban/nftables-api/main/install_nftables-api.sh | bash`

(or for a Pi)

`curl -sSL https://raw.githubusercontent.com/apiban/nftables-api/main/install_nftables-api-pi.sh | bash`

## Usage

It is recommended that you run nftables-api [as a service](#running-as-a-service-example), however you can run it however you like.

To run, simply set exe permissions (such as `chmod 755 nftables-api`) and run:

`./nftables-api`

### Default Settings

* port: `8084`
* log: `/var/log/nftables-api.log`
* setname: `APIBANLOCAL`
* logextra: `false` (add filename to log)
* ipv6: `true` (set to false to disable ipv6. ipv4 is always on)

Compiled `nftables-api` will work for most linux distributions and `nftables-api-pi` will work for most Raspberry Pi distributions.

You can also compile the program using `go build main.go`.

### Example with flags

`./nftables-api -p=8001 -s=BLOCKLIST -x=true -ipv6=false`

## Running as a Service (example)

If executable is in `/usr/local/nftables-api/`...

```bash
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
```

Log rotate...

```bash
cat > /etc/logrotate.d/nftables-api << EOF
/var/log/nftables-api.log {
        daily
        copytruncate
        rotate 12
        compress
}
EOF
```

## Kamailio Example

```bash
loadmodule "http_client.so"
loadmodule "htable.so"
... 
modparam("htable", "htable", "ipban=>size=8;autoexpire=600;")
... 
if (!pike_check_req()) {
  xlog("L_ALERT","ALERT: pike blocking $rm from $fu (IP:$si:$sp)\n");
  $sht(ipban=>$si) = 1;
  http_client_query("http://localhost:8084/add/$si", "$var(apinfo)");
  exit;
}
... 
event_route[htable:expired:ipban] {
  xlog("mytable record expired $shtrecord(key) => $shtrecord(value)\n");
  http_client_query("http://localhost:8084/unblock/$shtrecord(key)", "$var(apinfo)");
}
```

## API Usage

### List blocked IPs

* **URL**: /
* **METHOD**: `GET`
* **Auth**: None
* **RESPONSE**: 200

### List blocked IPs Examples

* GET `/`
* RESPONSE `200 OK`

```json
{"ipv4":["192.168.10.1"],"ipv6":["2001:dead:beef::1"]}
```

### Add/Block IP

Add an IP to nftables. nftables or ip6tables will be chosen based on the IP.

* **URL**: /[add|block/addip|blockip]/[ipaddress]
* **METHOD**: `GET`
* **Auth**: None
* **RESPONSE**: 200/4xx/5xx

or

* **URL**: `/`
* **METHOD**: `POST`
* **Auth**: None
* **RESPONSE**: 200/4xx/5xx

#### Add/Block Success Examples

* GET `/add/1.2.3.4`  
* RESPONSE `200 OK`

```json
{"success":"added"}
```

* GET `/block/2001:db8:3333:4444:5555:6666:7777:8888`
* RESPONSE `200 OK`

```json
{"success":"added"}
```

* POST `/` with `{"ipaddress":"1.2.3.4"}`  
* RESPONSE `200 OK`

```json
{"success":"added"}
```

#### Add/Block Error Examples

* GET `/addip/1.2.3`
* RESPONSE `400 Bad Request`

```json
{"error":"only valid ip addresses supported"}
```

* GET `/blockip/2001:db8:3333:4444:5555:6666:8888`
* RESPONSE `400 Bad Request`

```json
{"error":"only valid ip addresses supported"}
```

* POST `/` with `{"address":"1.2.3.4"}`  
* RESPONSE `400 Bad Request`

```json
{"error":"ipaddress is missing. "}
```

### Remove/Unblock IP

Remove an IP from nftables. [setname] or [setname]v6 will be chosen based on the IP.

* **URL**: /[remove|unblock|removeip|unblockip]/[ipaddress]
* **METHOD**: `GET`
* **Auth**: None
* **RESPONSE**: 200/4xx/5xx

or

* **URL**: `/`
* **METHOD**: `DELETE`
* **Auth**: None
* **RESPONSE**: 200/4xx/5xx

#### Remove/Unblock Success Examples

* GET `/removeip/1.2.3.4`  
* RESPONSE `200 OK`

```json
{"success":"deleted"}
```

* GET `/unblockip/2001:db8:3333:4444:5555:6666:7777:8888`
* RESPONSE `200 OK`

```json
{"success":"deleted"}
```

* DELETE `/` with `{"ipaddress":"1.2.3.4"}`  
* RESPONSE `200 OK`

```json
{"success":"deleted"}
```

#### Remove/Unblock Error Examples

* GET `/removeip/1.2.3`
* RESPONSE `400 Bad Request`

```json
{"error":"only valid ip addresses supported"}
```

* GET `/unblockip/2001:db8:3333:4444:5555:6666:8888`
* RESPONSE `400 Bad Request`

```json
{"error":"only valid ip addresses supported"}
```

* DELETE `/` with `{"address":"1.2.3.4"}`  
* RESPONSE `400 Bad Request`

```json
{"error":"ipaddress is missing. "}
```

### Flush APIBANLOCAL set

Flushes the APIBANLOCAL/APIBANLOCALv6 chain.

* **URL**: /[flush|flushset]
* **METHOD**: `GET`
* **Auth**: None
* **RESPONSE**: 200/4xx/5xx

#### Flush Success Example

* GET `/flush`  
* RESPONSE `200 OK`

```json
{"result":"ipv4 flushed. ipv6 flushed. "}
```

#### Flush Error Examples

* GET `/flush`
* RESPONSE `500 Internal Server Error`

```json
{"error":"error initializing nftables"}
```

* GET `/flush`  
* RESPONSE `200 OK`

```json
{"result":"ipv4 error. ipv6 flushed. "}
```

## License / Warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
