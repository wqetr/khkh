local function googlethat(query)
  local api = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&"
  local parameters = "q=".. (URL.escape(query) or "")
  local res, code = https.request(api..parameters)
  if code ~=200 then return nil  end
  local data = json:decode(res)
  local results = {}
  for key,result in ipairs(data.responseData.results) do
    table.insert(results, {
        result.titleNoFormatting,
        result.unescapedUrl or result.url
      })
  end
  return results
end

local function stringlinks(results)
  local stringresults="نتايج جستجوي گوگل:\n______________________________\n"
  for key,val in ipairs(results) do
    stringresults=stringresults..val[1].." - "..val[2].."\n"
  end
  return stringresults
end

local function run(msg, matches)
  local results = googlethat(matches[1])
  return stringlinks(results)
end

return {
  description = "Searche in Google",
  usagehtm = '<tr><td align="center">src مورد</td><td align="right">جست و جوی یک لغت یا جمله در گوگل و دریافت لینک 3جستجوی برتر</td></tr>',
  usage = "src (item) : جستجوي گوگل",
  patterns = {
    "^[Ss]rc (.*)$",
    "^%.[s|S]rc (.*)$"
  },
  run = run
}
