do
function run(msg)
	send_document("chat#id"..msg.to.id,"./file/qr.webp", ok_cb, false)
	return 'Umbrella Telegram Bot v2.0'.. [[ 
	
	Website:
	http://Umbrella.shayan-soft.IR
	Antispam Bot : @UmbrellaTG
	Channel : @UmbrellaTeam
	Sudo : @shayansoft
	
	Powered by:
	shayan soft Co. Group
	Engineer Shayan Ahmadi
	http://shayan-soft.IR
	
	Special Thanks:
	Uzzy
	Yagop
	Iman Daneshi
	and more...]]
end

return {
	description = "Robot and Creator About", 
	usagehtm = '<tr><td align="center">ver</td><td align="right">ارائه ی توضیحاتی در خصوص پروژه ی ربات آمبرلا و همچنین سازنده و توسئه دهنده ی آن</td></tr>',
	usage = "ver : درباره ربات",
	patterns = {
		"^[Vv]er$"
	}, 
	run = run 
}
end
