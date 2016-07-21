function run(msg, matches)
	local receiver = get_receiver(msg)
	local data = load_data(_config.moderation.data)
	if not data["gpusers"] then
		data["gpusers"] = {}
		save_data(_config.moderation.data, data)
	end
	if matches[1]:lower() == "join" and matches[2] then
		if not data["gpusers"][matches[2]:lower()] then
			return "یوزرنیم مورد نظر موجود نیست"
		else
			if data["gpusers"][matches[2]:lower()]["join"] == 0 then
				return "عضوگیری گروه مورد نظر از طریق یوزرنیم بسته است"
			else
				gpid = data["gpusers"][matches[2]:lower()]["gpid"]
				chat_add_user('chat#id'..gpid, "user#id"..msg.from.id, ok_cb, false)
				return "شما به گروه مورد نظر اضافه شدید. اگر این عمل انجام نشده است شماره ی ربات را ذخیره کنید یا در پی آن یک پیام ارسال کنید"
			end
		end
	end
	if not is_chat_msg(msg) then
		return "فقط در گروه"
	end
	if matches[1] == "user" and matches[2] and matches[3] and matches[4] == "-" or matches[4] == "+" then
		if not data["gpusers"]["#"..matches[3]:lower()] then
			return "یوزرنیم مورد نظر موجود نیست"
		elseif not data[tostring(gpid)]['moderators'][tostring(msg.from.id)] then
			return "شما در گروه مورد نظر مدیر نمیباشید"
		elseif matches[4] == "+" then
			data["gpusers"]["#"..matches[3]:lower()]["join"] = 1
			save_data(_config.moderation.data, data)
			return "عضوگیری از طریق یوزیرنیم باز شد"
		elseif matches[4] == "-" then
			data["gpusers"]["#"..matches[3]:lower()]["join"] = 0
			save_data(_config.moderation.data, data)
			return "عضوگیری از طریق یوزیرنیم بسته شد"
		end
	end
	if matches[1] == "user" then
		if not matches[3] then
			return "دستور را به شکل درست وارد کنید\n/user #username\nحتما قبل از یوزرنیم علامت # را بگذارید ضمنا یوزرنیم باید حداقل 6 حرف باشد"
		end
		if string.len(matches[3]) < 6 or string.len(matches[3]) > 15 then
			return "یوزرنیم باید حداقل 6 و حد اکثر 15 حرف باشد"
		end
		if data[tostring(msg.to.id)]['settings']['gp_user'] then
			return "گروه شما دارای یوزرنیم میباشد و هرگز تغییر نخواهد کرد"
		end
		if not tonumber(msg.from.id) == tonumber(gp_leader) then
			return "شما لیدر نیستید"
		end
		if not data["gpusers"]["#"..matches[3]:lower()] then
			data["gpusers"]["#"..matches[3]:lower()] = {
				gpid = msg.to.id,
				join = 1,
			}
			save_data(_config.moderation.data, data)
			data[tostring(msg.to.id)]['settings']['gp_user'] = "#"..matches[3]:lower()
			save_data(_config.moderation.data, data)
			return "یوزرنیم ثبت شد"
		else
			return "یوزرنیم مورد نظر از قبل موجود است"
		end
	end
	if matches[1]:lower() == "opengp" then
		local message = 'لیست گروه های باز برای عضویت:\n______________________________\n'
		i=1
		for k,v in pairs(data["gpusers"]) do
			if v.join == 1 then
				message = message..i..'- '..k..'\n'
				i=i+1
			end
		end
		return message
	end
end

return {
	description = "Robot and Group Moderation System", 
	usagehtm = "<tr><td align='center'>join #یوزرنیم</td><td align='right'>ورود به گروه با استفاده از یوزرنیم</td></tr>"
		.."<tr><td align='center'>/user #یوزرنیم</td><td align='right'>ثبت یوزرنیم برای گروه. دقت کنید دسترسی فقط برای لیدر است و به هیچ عنوان قابل تغییر نیست</td></tr>"
		.."<tr><td align='center'>/user #یوزرنیم -</td><td align='right'>بستن عضوگیری از طریق یوزرنیم</td></tr>"
		.."<tr><td align='center'>/user #یوزرنیم +</td><td align='right'>بازکردن عضوگیری از طریق یوزرنیم</td></tr>",
	usage = {
		user = {
			"join (#user) : ورود به گروه با یوزر",
			},
		moderator = {
			"/user (#user) : ثبت یوزر برای گروه",
			"/user (#user) +|- : باز بسته کردن عضوگیری",
			},
		},
	patterns = {
		"^/(user) (#)(.+) ([+-])$",
		"^/(user) (#)(.+)$",
		"^/(user) (.+)$",
		"^([Jj]oin) (.*)$",
		"^([Oo]pengp)$",
	}, 
	run = run,
}