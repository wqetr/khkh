do
local function sosender(text)
	local path = "http://onlinepanel.ir/post/sendsms.ashx?from=50001333343536&to=9351372038&text="
	local text = URL.escape(text)
	local param = "&password=11001100&username=9193033515"
	local url = path..text..param
	local res = http.request(url)
	if res == "1-0" then
		return 'پيام با موفقيت ارسال شد'
	else
		return 'خطا در ارسال\nشماره خطا: '..res
	end
end

local function run(msg, matches)
	local idtaraf = msg.from.id
	local idgroup = msg.to.id
	local nametaraf = msg.from.print_name
	local namegroup = msg.to.print_name
	moshakhasat = 'Name: '..nametaraf..'\n@'..(msg.from.username or '-----')..' ('..idtaraf..')\n'
				..'GP: '..namegroup..' ('..idgroup..')\n\n'..matches[1]
	local data = load_data(_config.moderation.data)
	local gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
	if not is_admin(msg) then
		if tonumber(msg.from.id) == tonumber(gp_leader) then
			return sosender(moshakhasat)
		else
			return "فقط لیدر ها میتوانند ارسال کنند"
		end
	else
		return sosender(moshakhasat)
	end
end

return {
	description = "Send SOS Messages to SUDO", 
	usagehtm = '<tr><td align="center">/sos متن</td><td align="right">ارسال مطالب خیلی اورژانسی به سودو از طریق پیامک</td></tr>',
	usage = {
		"/sos (pm) : ارسال مطالب اورژانسی",
	},
	patterns = {
		"^/sos (.+)",
	}, 
	run = run,
}
end