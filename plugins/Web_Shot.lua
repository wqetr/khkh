local helpers = require "OAuth.helpers"
local base = 'https://screenshotmachine.com/'
local url = base .. 'processor.php'
local function get_webshot_url(param)
	local response_body = {}
	local request_constructor = {
		url = url,
		method = "GET",
		sink = ltn12.sink.table(response_body),
		headers = {
			referer = base,
			dnt = "1",
			origin = base,
			["User-Agent"] = "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36"
		},
		redirect = false
	}
	local arguments = {
		urlparam = param,
		size = "FULL"
	}
	request_constructor.url = url .. "?" .. helpers.url_encode_arguments(arguments)
	local ok, response_code, response_headers, response_status_line = https.request(request_constructor)
	if not ok or response_code ~= 200 then
		return nil
	end
	local response = table.concat(response_body)
	return string.match(response, "href='(.-)'")
end

local function run(msg, matches)
	if is_admin(msg) then
		local find = get_webshot_url(matches[1])
		if find then
			local imgurl = base .. find
			local receiver = get_receiver(msg)
			send_photo_from_url(receiver, imgurl)
		end
	else
		return 'فقط ادمینها میتوانند از این قابلیت استفاده کنند'
	end
end

return {
	description = "Website Screen Shot",
	usagehtm = '<tr><td align="center">web آدرس سایت</td><td align="right">این قابلیت به شما این امکان را میدهد تا از وبسایتی عکس تهیه کنید. آدرس لینک به صورت زیر وارد شود:<br>http://آدرس وبسایت<br>مثال: http://www.shayan-soft.ir</td></tr>',
	usage = {
		admin = {
			"web (url) : گرفتن عکس از سايت",
		},
	},
	patterns = {
		"^[Ww]eb (https?://[%w-_%.%?%.:/%+=&]+)$",
	},
	run = run
}