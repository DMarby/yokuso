# Yokusō
[DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/) proxy for [Dropshare](https://getdropsha.re/), using [OpenResty](https://openresty.org).  
Yokusō makes it possible to use a private DigitalOcean Spaces space with Dropshare, without needing to store the API keys on your device.
It also caches the requests, for faster serving of the files you upload.

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
  -e BUCKET_REGION="<SPACES_REGION>" \
  -e ACCESS_KEY_ID="<SPACES_ACCESS_KEY>" \
  -e SECRET_ACCESS_KEY="<SPACES_SECRET_KEY>" \
  -e BUCKET_ENDPOINT="<SPACES_BUCKET_URL>" \
  -e ROOT_REDIRECT="http://google.com" \
  -e CLIENT_ACCESS_KEY_ID="<DROPSHARE_ACCESS_KEY>" \
  -e CLIENT_SECRET_ACCESS_KEY="<DROPSHARE_ACCESS_KEY>" \
  -e CLIENT_BUCKET_ENDPOINT="bucket.example.com" \
  yokuso:latest
```  

### Configuring Dropshare
You can now configure Dropshare, by adding a [Custom S3 API Compliant Connection](https://dropshare.zendesk.com/hc/en-us/articles/201139232-How-to-set-up-Amazon-S3-or-S3-API-compatible-connections).  
For access key and secret key, enter the values you specified in `CLIENT_ACCESS_KEY_ID` and `CLIENT_SECRET_ACCESS_KEY` above. Note that the `CLIENT_BUCKET_ENDPOINT` above needs to be the `<BUCKET_NAME>.<SERVER>` that you specify in your Dropshare configuration.

## Thanks to
* [Kamal Nasser](https://kamal.io) for making the error page.
* [Moriyoshi Koizumi](https://github.com/moriyoshi) for [their work](https://github.com/DMarby/api-gateway-aws/commit/35fd7af0d9783247a3085bacac3421038f382432) extending api-gateway-aws.
* [Hector Castro](https://github.com/hectcastro) for creating [docker-s3-proxy-cache](https://github.com/azavea/docker-s3-proxy-cache) which inspired this project.