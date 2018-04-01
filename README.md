# Yokusō
[DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/) proxy for [Dropshare](https://getdropsha.re/), using [OpenResty](https://openresty.org).  
Yokusō makes it possible to use a private DigitalOcean Space with Dropshare, without needing to store the API keys on your device.  
It also caches the requests, to serve the files you upload faster.

## Usage

### Running the service
To run Yokusō, it's recommended to use Docker.
To start off, build the container:  
```
docker build -t yokuso:latest .
```
You can now run it with the following command:
```
docker run \
  -p 80:80 \
  -v /var/cache/nginx:/var/cache/nginx \
  -e SPACES_REGION="<SPACES_REGION>" \
  -e ACCESS_KEY_ID="<SPACES_ACCESS_KEY>" \
  -e SECRET_ACCESS_KEY="<SPACES_SECRET_KEY>" \
  -e SPACES_ENDPOINT="<SPACES_URL>" \
  -e ROOT_REDIRECT="http://google.com" \
  -e CLIENT_ACCESS_KEY_ID="<DROPSHARE_ACCESS_KEY>" \
  -e CLIENT_SECRET_ACCESS_KEY="<DROPSHARE_ACCESS_KEY>" \
  yokuso:latest
```  

### Configuring Dropshare
You can configure Dropshare by adding a [Custom S3 API Compliant Connection](https://dropshare.zendesk.com/hc/en-us/articles/201139232-How-to-set-up-Amazon-S3-or-S3-API-compatible-connections).  

If you are not using path-style URLs, Yokusō will need to run on a subdomain.
Set the `server` in drop share to the main domain, and `bucket name` to the subdomain (e.g. if Yokusō is running on `dump.dmarby.se`, the `server` would be `dmarby.se`, and the `bucket name` would be `dump`.  

If you are using path-style URLs, set the `server` to the domain where Yokusō is running, and the `bucket name` to anything.  

For access key and secret key, enter the values you specified in `CLIENT_ACCESS_KEY_ID` and `CLIENT_SECRET_ACCESS_KEY` above.

## Thanks to
* [Kamal Nasser](https://kamal.io) for making the error page.
* [Moriyoshi Koizumi](https://github.com/moriyoshi) for [their work](https://github.com/DMarby/api-gateway-aws/commit/35fd7af0d9783247a3085bacac3421038f382432) extending api-gateway-aws.
* [Hector Castro](https://github.com/hectcastro) for creating [docker-s3-proxy-cache](https://github.com/azavea/docker-s3-proxy-cache) which inspired this project.
