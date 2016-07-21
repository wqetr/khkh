local baseapi = "http://ip-api.com/"
local function get_config(areal)
	local parameters = (URL.escape(areal) or "")
	local lat = http.request(baseapi.."csv/"..parameters.."?fields=16384")
	if lat == "success" then
		local parameters = (URL.escape(areal) or "")
		local res = "کشور: "..http.request(baseapi.."line/"..parameters.."?fields=1")
		local res = res.."استان: "..http.request(baseapi.."line/"..parameters.."?fields=8")
		local res = res.."شهر: "..http.request(baseapi.."line/"..parameters.."?fields=16")
		local res = res.."آي اس پي: "..http.request(baseapi.."line/"..parameters.."?fields=512")
		local res = res.."اورگانيزيشن: "..http.request(baseapi.."line/"..parameters.."?fields=1024")
		local res = res.."اي اس: "..http.request(baseapi.."line/"..parameters.."?fields=2048")
		return res
	else
		return "مقدار وارد شده صحيح نيست"
	end
end

local function get_local(receiver, areal)
	local parameters = (URL.escape(areal) or "")
	local lat = http.request(baseapi.."csv/"..parameters.."?fields=16384")
	if lat == "success" then
		local parameters = (URL.escape(areal) or "")
		local lat = http.request(baseapi.."csv/"..parameters.."?fields=64")
		local lon = http.request(baseapi.."csv/"..parameters.."?fields=128")
		local res1 = http.request(baseapi.."csv/"..parameters.."?fields=1")
		local res2 = http.request(baseapi.."csv/"..parameters.."?fields=8")
		local res3 = http.request(baseapi.."csv/"..parameters.."?fields=16")
		send_location(receiver, lat, lon, ok_cb, false)
	return "آدرس:\n"..res1.." , "..res2.." , "..res3.."\n"
		.."مختصات جغرافي:\n"..lat..","..lon.."\n"
		.."لينک گوگل مپ:\nhttps://www.google.com/maps/place/"..lat..","..lon
	else
		return "مقدار وارد شده صحيح نيست"
	end
end

local function get_ping(areal)
	local parameters = (URL.escape(areal) or "")
	local lat = http.request(baseapi.."csv/"..parameters.."?fields=16384")
	local latip = http.request(baseapi.."csv/"..parameters.."?fields=8192")
	if lat == "success" then
		return areal.." = "..latip.." Online"
	else
		return "خارج از سرويس"
	end
end

local function get_iptoken(token)
	local gettoken = http.request("http://umbrella.shayan-soft.ir/82.txt")
	return gettoken
end

local function get_whois(areal)
	local parameters = (URL.escape(areal) or "")
	local lat = http.request(baseapi.."csv/"..parameters.."?fields=16384")
	if lat == "success" then
		return "دامنه مورد نظر ثبت شده است\nمشخصات ثبت کننده: \n".."http://www2.parstools.com/whois/show/?domain="..areal
	else
		return "دامنه مورد نظر آزاد است\nجهت ثبت آن به آدرس زير مراجعه کنيد\nhttp://nic.ir"
	end
end

local function get_urlip(areal)
	local parameters = (URL.escape(areal) or "")
	local lat = http.request(baseapi.."csv/"..parameters.."?fields=16384")
	if lat == "success" then
		local parameters = (URL.escape(areal) or "")
	local res = "آي پي سايت مورد نظر: \n"..http.request(baseapi.."line/"..parameters.."?fields=8192")
		return res
	else
		return "مقدار وارد شده صحيح نيست"
	end
end

local function run(msg, matches)
	if matches[1] == "onfig" then
		return get_config(matches[2])
	elseif matches[1] == "etloc" then
		local receiver = get_receiver(msg)
		return get_local(receiver, matches[2])
	elseif matches[1] == "ing" then
		if matches[2] == "." then
			return "207.122.43.11 = 207.122.43.11 Online"
		else
			return get_ping(matches[2])
		end
	elseif matches[1] == "hois" then
		return get_whois(matches[2])
	elseif matches[1] == "rlip" then
		if matches[2] == "." then
			return "آي پي سايت مورد نظر: \n207.122.43.11"
		else
			return get_urlip(matches[2])
		end
	elseif matches[1] == "ptoken" then
	--	if not matches[2] then
			return 'برای مشاهده ی آی پی دیگران آدرس زیر را به آنان بدهید و توکنی که سایت به آنها میدهد را از ایشان بخواهید و با درج یک فاصله آن را بعد از دستور iptoken وارد نمایید\nhttp://umbrella.html-5.me'
	--	else
	--		return get_iptoken(matches[2])
	--	end
	elseif matches[1] == "p" then
		return "براي مشاهده ي آي پي خود به لينک زير مراجعه کنيد\nhttp://umbrella.shayan-soft.ir/ip"
	end
end

return {
	description = "IP and URL Information", 
	usagehtm = '<tr><td align="center">ip</td><td align="right">لینکی در اختیارتان قرار میدهد که با ورود به آن میتوانید آی پی خود را مشاهده کنید</td></tr>'
	--..'<tr><td align="center">iptoken</td><td align="right">لینک ارائه شده را به شخص مورد نظر بدهید و از آن توکنی که سایت به او میدهد را بخواهید. اگر آن توکن را با یک فاصله بعد از همین دستور وارد کنید، آی پی شخص مورد نظر نمایش داده میشد</td></tr>'
	..'<tr><td align="center">config آی پی یا لینک</td><td align="right">اطلاعاتی کلی راجع به آن لینک یا آی پی در اختیارتان قرار میدهد. دقت کنید لینک بدون اچ تی تی پی وارد شود</td></tr>'
	..'<tr><td align="center">getloc آی پی یا لینک</td><td align="right">محل آی اس پی یعنی سرویس دهنده ی اینترنتی آی پی یا سرور مورد نظر را به شما میگوید. دقت کنید لینک بدون اچ تی تی پی وارد شود</td></tr>'
	..'<tr><td align="center">ping  آی پی یا لینک</td><td align="right">از سرور با پورت 80 پینگ میگیرد. دقت کنید لینک بدون اچ تی تی پی وارد شود</td></tr>'
	..'<tr><td align="center">whois لینک</td><td align="right">یک دامین را بررسی میکند و در صورتی که قبلا به ثبت رسیده باشد، مشخصات ثبت کننده را به اطلاع شما میرسان. دقت کنید لینک بدون اچ تی تی پی وارد شود</td></tr>'
	..'<tr><td align="center">urlip لینک</td><td align="right">آی پی سرور مورد نظر را از روی لینک به دست آورده و ارائه میکند. دقت کنید لینک بدون اچ تی تی پی وارد شود</td></tr>',
	usage = {
		"ip : آي پي شما",
	--	"iptoken : ذخیره آی پی دیگران",
	--	"iptoken (token) : نمایش ذخیره شده",
		"config (ip|url) : مشخصات",
		"getloc (ip|url) : مکان",
		"ping (ip|url) : پينگ",
		"whois (url) : بررسي دامنه",
		"urlip (url) : آي پي سايت",
	},
	patterns = {
		"^[Ii](p)$",
	--	"^[Ii](ptoken)$",
	--	"^[Ii](ptoken) (.*)$",
		"^[Cc](onfig) (.*)$",
		"^[Gg](etloc) (.*)$",
		"^[Pp](ing) (.*)$",
		"^[Ww](hois) (.*)$",
		"^[Uu](rlip) (.*)$",
	}, 
	run = run
}