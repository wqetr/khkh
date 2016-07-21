local text = "Umbrella Super Spammer Bot"
local text = text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"
local text = text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"..text.."\n"
local function run(msg, matches)
	local receiver = get_receiver(msg)
    if matches[1] == "spam" then
        for i=1,100 do
            send_large_msg(receiver, text)
        end
	else
	    local text = "Umbrella Super Spammer Bot"
		local num = tonumber(matches[2])
        for i=1,num do
			if i == 99 then
				return 'ارسال اسپم بیش از 100 عدد مجاز نیست'
			end
            send_large_msg(receiver, text)
        end
	end
end
 
return {
	description = "Send Spam PMs",
	usagehtm = '<tr><td align="center">/spam</td><td align="right">ارسال یکصد پیام طولانی</td></tr>'
	..'<tr><td align="center">spam عدد</td><td align="right">ارسال پیام اسپم به تعداد دلخواه</td></tr>',
	usage = {
	admin = {
		"/spam : اسپم اتوماتیک",
		"spam (num) : اسپم تعدادي",
	},
	},
	patterns = {
		"^/(spam)$",
		"^[Ss](pam) (.+)$",
	},
	run = run,
	privileged = true
}