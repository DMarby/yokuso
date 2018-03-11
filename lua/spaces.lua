local AWSV4S = require "api-gateway.aws.AwsV4Signature"
local purge_cache = require "purge_cache"
local target_uri = ngx.var.uri
local request_method = ngx.var.request_method
local headers = ngx.req.get_headers()
local uri_args = {}

-- Read body
ngx.req.read_body()
local request_body = ngx.req.get_body_data()
if not request_body then
  local request_body_file_name = ngx.req.get_body_file()
  if request_body_file_name then
    file = io.open(request_body_file_name)
    request_body = file:read("*a")
    file:close()
  end
end

-- For uploads we want to validate credentials
if request_method == "PUT" or request_method == "DELETE" then
  uri_args = ngx.req.get_uri_args() -- Set uri_args from request so that we pass them along to the request to spaces
  local client_access_key = os.getenv("CLIENT_ACCESS_KEY_ID")
  local req_access_key, req_signed_headers, req_signature = string.match(headers["Authorization"], ".+ Credential=(%w+)/.+, SignedHeaders=(.+), Signature=(.+)")

  -- Access key does not match
  if client_access_key ~= req_access_key then
    ngx.exit(403)
  end

  local clientAuth = AWSV4S:new({
    aws_region = "us-east-1",
    aws_access_key = client_access_key,
    aws_secret_key = os.getenv("CLIENT_SECRET_ACCESS_KEY"),
    aws_service = "s3"
  })

  local headers_to_sign = {}
  for header in string.gmatch(req_signed_headers, '([^;]+)') do
    table.insert(headers_to_sign, {header, headers[header]})
  end

  local auth_signature = clientAuth:getSignatureWithHeaders(request_method, target_uri, uri_args, request_body, headers_to_sign, headers["x-amz-date"])

  -- Signature does not match
  if auth_signature ~= req_signature then
    ngx.exit(403)
  end

   -- Rewrite path-style url's to remove the bucket from them
  if os.getenv("PATH_STYLE_URL") ~= nil then
    target_uri = string.match(target_uri, "/.+(/.+)")
    ngx.req.set_uri(target_uri)
  end

  -- Purge the cache after deleting an object
  if request_method == "DELETE" then
    purge_cache(target_uri, "/var/cache/nginx", "1:2")
  end
end

local spaces_auth = AWSV4S:new({
  aws_region = os.getenv("BUCKET_REGION"),
  aws_access_key = os.getenv("ACCESS_KEY_ID"),
  aws_secret_key = os.getenv("SECRET_ACCESS_KEY"),
  aws_service = "s3",
  private = true
})

-- Create signature
local authorization_header, content_hash = spaces_auth:getAuthorizationHeader(
  request_method,
  target_uri,
  uri_args,
  request_body,
  os.getenv("BUCKET_ENDPOINT")
)

-- Set required headers
ngx.req.set_header("Authorization", authorization_header)
ngx.req.set_header("x-amz-date", spaces_auth.aws_date)
ngx.req.set_header("x-amz-content-sha256", content_hash)
ngx.req.set_header("x-amz-acl", "private")
