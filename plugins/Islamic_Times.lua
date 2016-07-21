local function run(msg, matches)
	local res = http.request("http://api.aladhan.com/timingsByCity?city="..URL.escape(matches[1]).."&country=IR&method=2")
	local jtab = JSON.decode(res)
	if jtab.status == "OK" then
		return "اوقات شرعی امروز "..matches[1].."\n\n"
			.."اذان صبح: "..jtab.data.timings.Fajr.."\n"
			.."طلوع آفتاب: "..jtab.data.timings.Sunrise.."\n"
			.."اذان ظهر: "..jtab.data.timings.Dhuhr.."\n"
			--.."عصر: "..jtab.data.timings.Asr.."\n"
			--.."غروب آفتاب: "..jtab.data.timings.Sunset.."\n"
			.."اذان مغرب: "..jtab.data.timings.Maghrib --.."\n"
			--.."اشا: "..jtab.data.timings.Isha
	else
		return "مکان وارد شده صحیح نیست یا در ایران نمیباشد"
	end
end

return {
	description = "Islamic Times",
	usagehtm = '<tr><td align="center">azan شهر</td><td align="right">نمایش اوقات شرعی شهرهای ایران. میتوانید نام شهر را لاتین یا فارسی وارد کنید</td></tr>',
	usage = {"azan (city) : اوقات شرعی"},
	patterns = {"^[Aa]zan (.*)$"},
	run = run,
}