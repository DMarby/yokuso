--- http://lua-users.org/wiki/StringRecipes

function starts_with(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

return starts_with
