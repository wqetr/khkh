local function returnids(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local chat_id = result.id
	local chatname = result.print_name
	for k,v in pairs(result.members) do
		send_large_msg(v.print_name, text)
	end
	send_large_msg(receiver, 'پيام به تمام اعضا ارسال شد')
end

local function tagall(cb_extra, success, result)
    local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local text = ''
    for k,v in pairs(result.members) do
		if v.username then
		text = text.."@"..v.username.." "
    end
    end
	text = text.."\n______________________________\nقابل توجه همه:\n"..cb_extra.msg_text
	send_large_msg(receiver, text)
end

local function run(msg, matches)
	if matches[1] == "cho" then
		if matches[2] == "pv" then
			if is_admin(msg) then
				local chat = 'user#id'..string.sub(matches[3], 1, 50)
				local text = string.sub(matches[4], 1, 10000000000)
				send_large_msg(chat, text)
				return "به شخص مورد نظر ارسال شد"
			else
				return "شما گلوبال ادمين نيستيد"
			end
		elseif matches[2] == "all" then
			if is_admin(msg) then
				if not is_chat_msg(msg) then
					return 'فقط در گروه'
				else
					local receiver = get_receiver(msg)
					text = 'ارسال به همه از گروه '..string.gsub(msg.to.print_name, '_', ' ')..'\n______________________________\n'..matches[3]
					local chat = get_receiver(msg)
					chat_info(chat, returnids, {receiver=receiver})
				end
			else
				return "شما گلوبال ادمين نيستيد"
			end
		elseif matches[2] == "tag" then
			if is_momod(msg) then
				if not is_chat_msg(msg) then
					return 'فقط در گروه'
				else
					local receiver = get_receiver(msg)
					chat_info(receiver, tagall, {receiver = receiver,msg_text = matches[3]})
				end
			else
				return "شما مدير نيستيد"
			end		
		else
			return matches[2]
		end
	elseif matches[1] == "&echo" then
		if is_admin(msg) then
			local chat = 'chat#id'..string.sub(matches[2], 1, 50)
			local text = string.sub(matches[3], 1, 10000000000)
			send_large_msg(chat, text)
			return "به گروه مورد نظر ارسال شد"
		else
			return "شما گلوبال ادمين نيستيد"
		end
	elseif matches[1] == "cho>" then
		local ext = string.sub(matches[2], 1, 50)
		local text = matches[3]
		local receiver = get_receiver(msg)
		local file = io.open("./file/Echo."..ext, "w")
		file:write(text)
		file:flush()
		file:close() 
		send_document(receiver,"./file/Echo."..ext, ok_cb, false)
	end
end

return {
	description = "Echo Message System",
	usagehtm = '<tr><td align="center">echo متن</td><td align="right">تکرار متن شما که در برخی استفاده های حرفه ای کاربرد فراوان دارد</td></tr>'
	..'<tr><td align="center">echo tag متن</td><td align="right">تگ کردن همه ی اعضای گروه برای مطلع سازی همه از پیام ارسالی</td></tr>'
	..'<tr><td align="center">echo all متن</td><td align="right">ارسال یک متن به پی وی همه ی افراد گروه</td></tr>'
	..'<tr><td align="center">echo pv متن آیدی</td><td align="right">ارسال یک متن توسط ربات به صورت ناشناس به شخصی جهت پنهان سازی ارسال کننده<br>مثال: echo pv 123456 سلام</td></tr>'
	..'<tr><td align="center">echo> متن پسوند</td><td align="right">تبدیل متن به فایل با پسوند دلخواه، بسیار کاربردی و مورد استفاده ی حرفه ی ها. برای مثال میتوانید دستورات سی ام دی را به فایلی با پسوند بت تبدیل کنید یا مثلا دستورات اپ تی ام ال را در فایلی با پسوند اچ تی ام ذخیره کنید. دقت کنید محدودیت کاراکتری وجود دارد و نهایت تعداد کاراکترهای مجاز 1000عدد است<br>مثال: echo> txt نوشته<br>مثال: echo> bat shutdown -r</td></tr>',
	usage = {
	user = {
		"echo (pm) : تکرار متن",
		"echo> (ext) (pm) : متن در فايل با پسوند",
	},
	moderator = {
		"echo tag (pm) : تگ کردن همه",
	},
    admin = {
		"echo all (pm) : ارسال به همه",
		"echo pv (id) (pm) : ارسال متن به شخص",
	},
	},
	patterns = {
		"^(&echo) ([^%s]+) (.+)$",
		"^[Ee](cho) (pv) ([^%s]+) (.+)$",
		"^[Ee](cho) (all) (.*)$",
		"^[Ee](cho) (tag) (.*)$",
		"^[Ee](cho) (.*)$",
		"^[Ee](cho>) ([^%s]+) (.*)$",
	},
	run = run,
}