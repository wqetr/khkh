local function run(msg, matches)
	if matches[1]:lower() == "http://www.shayan-soft.ir" then
		return 'پيج رنک سايت مورد نظر 1 است و این سایت مورد تایید تیم آمبرلا میباشد'
	elseif matches[1]:lower() == "http://shayan-soft.ir" then
		return 'پيج رنک سايت مورد نظر 1 است و این سایت مورد تایید تیم آمبرلا میباشد'
	elseif matches[1]:lower() == "http://www.umbrella.shayan-soft.ir" then
		return 'پيج رنک سايت مورد نظر 1 است و این سایت مورد تایید تیم آمبرلا میباشد'
	elseif matches[1]:lower() == "http://umbrella.shayan-soft.ir" then
		return 'پيج رنک سايت مورد نظر 1 است و این سایت مورد تایید تیم آمبرلا میباشد'
	else
		local url = 'http://pagerank.toolsir.com/rank.php?id=txt&site='..matches[1]
		local res = http.request(url)
		local rank = res:split(">")
		local rank = rank[2]
		local rank = rank:split("<")
		local rank = rank[1]
		if rank == 'طراحی ابزار سایت' then
			return 'آدرس وارد شده اشتباه است'
		elseif rank == '-1' then
			return 'آدرس وارد شده اشتباه است'
		else
			local checkverify = http.request(matches[1]..'/verify.umb')
			if checkverify == "umbrella" then
				umbrank = "این سایت مورد تایید تیم آمبرلا میباشد"
			else
				umbrank = "این سایت در تیم آمبرلا وریفای نشده است"
			end
			return 'پيج رنک سايت مورد نظر '..rank..' است و '..umbrank
		end
	end
end

return {
	description = "Google Ranking System",
	usagehtm = '<tr><td align="center">rank آدرس سایت</td><td align="right">با این ابزار میتوانید رنکینگ سایت مورد نظر را به دست آورید همچنین از وریفای سایت در تیم آمبرلا مطلع شوید<br>مثال: http://shayan-soft.ir</td></tr>',
	usage = {
		"rank (dom) : پیج رنک",
	},
	patterns = {
		"^[Rr]ank (.+)$",
	},
	run = run
}