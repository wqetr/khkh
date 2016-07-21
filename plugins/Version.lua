do
function run(msg)
	send_document("chat#id"..msg.to.id,"./file/qr.webp", ok_cb, false)
	return 'blaster Telegram Bot v2.0'.. [[ 
	
	Channel : @fucker_Team
	Sudo : @nethall
	
	Powered by:
        @nethall
	
	Special Thanks:
	Uzzy
	Yagop
	Iman Daneshi
	tg_break
end

return {
	description = "Robot and Creator About", 
	usagehtm = '<tr><td align="center">ver</td><td align="right">ارائه ی توضیحاتی در خصوص پروژه ی رباتنواا و همچنین سازنده و توسئه دهنده ی آن</td></tr>',
	usage = "ver : درباره ربات",
	patterns = {
		"^[Vv]er$"
	}, 
	run = run 
}
end
