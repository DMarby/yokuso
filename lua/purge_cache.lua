-- Based on https://scene-si.org/2016/11/02/purging-cached-items-from-nginx-with-lua/

local resty_md5 = require "resty.md5"
local str = require "resty.string"

function cache_filename(cache_path, cache_levels, cache_key)
  local md5 = resty_md5:new()
  if not md5 then
    return
  end

  local ok = md5:update(cache_key)
  if not ok then
    return
  end

  local md5_sum = str.to_hex(md5:final())

  -- Nginx creates a directory for each cache level
  -- The directory name length is specified for each level, eg "1:2" creates the folder structure x/yz/filename
  -- The directory name is the suffix of the filename, minus the level, eg a filename of foobarxyz with a level configuration of "1:2" would result in z/xy/foobar
  local filename = ""
  local index = string.len(md5_sum)
  for level in string.gmatch(cache_levels, '%d+') do
    local length = tonumber(level)
    index = index - length
    filename = filename .. md5_sum:sub(index+1, index+length) .. "/"
  end

  return cache_path .. "/" .. filename .. md5_sum
end

function purgeCache(request_uri, cache_path, cache_levels)
  os.remove(cache_filename(cache_path, cache_levels, "GET" .. os.getenv("SPACES_ENDPOINT") .. request_uri))
  os.remove(cache_filename(cache_path, cache_levels, "HEAD" .. os.getenv("SPACES_ENDPOINT") .. request_uri))
end

return purgeCache
