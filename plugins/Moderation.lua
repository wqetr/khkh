do
local function check_member(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local data = cb_extra.data
	local msg = cb_extra.msg
	for k,v in pairs(result.members) do
		local member_id = v.id
		if member_id ~= our_id then
			local username = v.username
			data[tostring(msg.to.id)] = {
				moderators ={},
				settings = {
					set_name = string.gsub(msg.to.print_name, '_', ' '),
					lock_name = 'yes',
					lock_photo = 'no',
					lock_member = 'no',
					lock_link = 'yes',
					lock_channel = 'yes',
					lock_sticker = 'no',
					lock_bot = 'yes',
					lock_filter = 'yes',
					lock_spam = 'yes',
					spam_action = '5',
					gp_model = 'vip',
					gp_chatter = 'yes',
					gp_welcome = 'yes',
					gp_language = 'fa',
					gp_leader = '0'
					}	
				}
			save_data(_config.moderation.data, data)
			return
		end
	end
end

local function automodadd(msg)
    local data = load_data(_config.moderation.data)
	if msg.action.type == 'chat_created' then
		receiver = get_receiver(msg)
		chat_info(receiver, check_member,{receiver=receiver, data=data, msg = msg})
	else
		if data[tostring(msg.to.id)] then
			return 'گروه داراي بخش مديريت ميباشد'
		end
		if msg.from.username then
			username = msg.from.username
		else
			username = msg.from.print_name
		end
		data[tostring(msg.to.id)] = {
			moderators ={},
			settings = {
				set_name = string.gsub(msg.to.print_name, '_', ' '),
				lock_name = 'yes',
				lock_photo = 'no',
				lock_member = 'no',
				lock_link = 'yes',
				lock_channel = 'yes',
				lock_sticker = 'no',
				lock_bot = 'yes',
				lock_filter = 'yes',
				lock_spam = 'yes',
				spam_action = '5',
				gp_model = 'vip',
				gp_chatter = 'yes',
				gp_welcome = 'yes',
				gp_language = 'fa',
				gp_leader = '0'
				}
			}
		save_data(_config.moderation.data, data)
	end
end

local function defaultsettings(msg)
    local data = load_data(_config.moderation.data)
	data[tostring(msg.to.id)] = {
		moderators ={},
		settings = {
			set_name = string.gsub(msg.to.print_name, '_', ' '),
			lock_name = 'yes',
			lock_photo = 'no',
			lock_member = 'no',
			lock_link = 'yes',
			lock_channel = 'yes',
			lock_sticker = 'no',
			lock_bot = 'yes',
			lock_filter = 'yes',
			lock_spam = 'yes',
			spam_action = '5',
			gp_model = 'vip',
			gp_chatter = 'yes',
			gp_welcome = 'yes',
			gp_language = 'fa',
			gp_leader = msg.from.id
			}
		}
	save_data(_config.moderation.data, data)
	return 'تنظیمات به حالت اول برگشت'
end

local function modadd(msg)
    if not is_admin(msg) then
        return "شما گلوبال ادمين نيستيد"
    end
    local data = load_data(_config.moderation.data)
	if data[tostring(msg.to.id)] then
		return 'گروه داراي بخش مديريت ميباشد'
	end
	data[tostring(msg.to.id)] = {
		moderators ={},
		settings = {
			set_name = string.gsub(msg.to.print_name, '_', ' '),
			lock_name = 'yes',
			lock_photo = 'no',
			lock_member = 'no',
			lock_link = 'yes',
			lock_channel = 'yes',
			lock_sticker = 'no',
			lock_bot = 'yes',
			lock_filter = 'yes',
			lock_spam = 'yes',
			spam_action = '5',
			gp_model = 'vip',
			gp_chatter = 'yes',
			gp_welcome = 'yes',
			gp_language = 'fa',
			gp_leader = '0'
			}
		}
	save_data(_config.moderation.data, data)
	return 'بخش مديريت افزود شد'
end

local function modrem(msg)
    if not is_admin(msg) then
        return "شما گلوبال ادمين نيستيد"
    end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if not data[tostring(msg.to.id)] then
		return 'گروه داراي بخش مديريت نميباشد'
	end
	data[tostring(msg.to.id)] = nil
	save_data(_config.moderation.data, data)
	return 'بخش مديريت حذف شد'
end

local function promote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
	if not data[group] then
		return send_large_msg(receiver, 'گروه بخش مدیریت ندارد')
	end
	if data[group]['moderators'][tostring(member_id)] then
		return send_large_msg(receiver, '@'..member_username..' مدير ميباشد')
	end
    data[group]['moderators'][tostring(member_id)] = member_username
    save_data(_config.moderation.data, data)
    return send_large_msg(receiver, '@'..member_username..' مدير شد')
end

local function demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
	if not data[group] then
		return send_large_msg(receiver, 'گروه بخش مدیریت ندارد')
	end
	if not data[group]['moderators'][tostring(member_id)] then
		return send_large_msg(receiver, '@'..member_username..' مدير نيست')
	end
	data[group]['moderators'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' از مديريت برکنار شد')
end

local function admin_promote(receiver, member_username, member_id)  
	local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end
	if data['admins'][tostring(member_id)] then
		return send_large_msg(receiver, '@'..member_username..' گلوبال ادمين ميباشد')
	end
	data['admins'][tostring(member_id)] = member_username
	save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' گلوبال ادمين شد')
end

local function admin_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end
	if not data['admins'][tostring(member_id)] then
		return send_large_msg(receiver, '@'..member_username..' گلوبال ادمين نيست')
	end
	data['admins'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' از گلوبال ادميني برکنار شد')
end

local function username_id(cb_extra, success, result)
	local mod_cmd = cb_extra.mod_cmd
	local receiver = cb_extra.receiver
	local member = cb_extra.member
	local text = '@'..member..' در گروه نيست'
	for k,v in pairs(result.members) do
		vusername = v.username
		if vusername == member then
			member_username = member
			member_id = v.id
			if mod_cmd == 'odset' then
				return promote(receiver, member_username, member_id)
			elseif mod_cmd == 'oddem' then
				return demote(receiver, member_username, member_id)
			elseif mod_cmd == 'dminset' then
				return admin_promote(receiver, member_username, member_id)
			elseif mod_cmd == 'dmindem' then
				return admin_demote(receiver, member_username, member_id)
			end
		end
	end
	send_large_msg(receiver, text)
end

local function callbackinfo(extra, success, result)
	userinfoid = 'مشخصات لیدر و مالک گروه:\nنام: '..result.print_name..'\nیوزر: @'..(result.username or '-----')..'\nآیدی: '..result.id
    local data = load_data(_config.moderation.data)
	if next(data[tostring(resultgp.to.id)]['moderators']) == nil then
		local message = string.gsub(resultgp.to.print_name, '_', ' ')..' ليست مديران گروه:\n______________________________\n'..userinfoid..'\n______________________________\nگروه مدير ندارد'
		local chat = 'chat#id'..resultgp.to.id
		return send_large_msg(chat, message)
	end
	local message = string.gsub(resultgp.to.print_name, '_', ' ')..' ليست مديران گروه:\n______________________________\n'..userinfoid..'\n______________________________\n'
	i=1
	for k,v in pairs(data[tostring(resultgp.to.id)]['moderators']) do
		message = message..i..'- @'..v..' ('..k..')\n'
		i=i+1
	end
	local chat = 'chat#id'..resultgp.to.id
	return send_large_msg(chat, message)
end

local function modlist(msg)
	gp_leader = userinfoid
    local data = load_data(_config.moderation.data)
	if next(data[tostring(msg.to.id)]['moderators']) == nil then
		local message = string.gsub(msg.to.print_name, '_', ' ')..' ليست مديران گروه:\n______________________________\n'..gp_leader..'\n______________________________\nگروه مدير ندارد'
		return message
	end
	local message = string.gsub(msg.to.print_name, '_', ' ')..' ليست مديران گروه:\n______________________________\n'..(gp_leader or "-----")..'\n______________________________\n'
	i=1
	for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
		message = message..i..'- @'..v..' ('..k..')\n'
		i=i+1
	end
	return message
end

local function admin_list(msg)
    local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end
	if next(data['admins']) == nil then
		return 'گلوبال ادمين وجود ندارد'
	end
	local message = 'گلوبال ادمینهای ربات آمبرلا:\n______________________________\nSudo : @shayansoft (70459880)\n'
	i=1
	for k,v in pairs(data['admins']) do
		message = message..i..'- @'.. v ..' ('..k..')\n'
		i=i+1
	end
	return message
end

local function get_message_callback_id(extra, success, result)
	local chat = 'chat#id'..result.to.id
	local data = load_data(_config.moderation.data)
	data[tostring(result.to.id)]['settings']['gp_leader'] = result.from.id
	save_data(_config.moderation.data, data)
	send_large_msg(chat, 'لیدر ثبت شد')
end

function run(msg, matches)
	if not is_chat_msg(msg) then
		return "فقط در گروه"
	end
	local mod_cmd = matches[1]
	local receiver = get_receiver(msg)
	
	if matches[1] == 'eaderset' and msg.reply_id and is_admin(msg) then
		return get_message(msg.reply_id, get_message_callback_id, false)
	end
	
	if matches[1] == '/modadd' and is_sudo(msg) then
		return modadd(msg)
	end
	
	if matches[1] == '/modrem' and is_sudo(msg) then
		return modrem(msg)
	end
	
	if matches[1] == 'odset' and matches[2] then
		local data = load_data(_config.moderation.data)
		local gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
		if tonumber(msg.from.id) == tonumber(gp_leader) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		elseif is_admin(msg) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		elseif is_sudo(msg) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		else
			return "فقط لیدر ميتواند مدير تايين کند"
		end
	end
	
	if matches[1] == 'reset' then
		local data = load_data(_config.moderation.data)
		local gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
		if tonumber(msg.from.id) == tonumber(gp_leader) then
			return defaultsettings(msg)
		elseif is_admin(msg) then
			return defaultsettings(msg)
		elseif is_sudo(msg) then
			return defaultsettings(msg)
		else
			return "فقط لیدر ميتواند تنظیمات را ریست کند"
		end
	end
	
	if matches[1] == 'oddem' and matches[2] then
		local data = load_data(_config.moderation.data)
		local gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
		if tonumber(msg.from.id) == tonumber(gp_leader) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		elseif is_admin(msg) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		elseif is_sudo(msg) then
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		else
			return "فقط لیدر ميتواند مدير برکنار کند"
		end	
	end
	
	if matches[1] == 'eaderset' and matches[2] then
		local data = load_data(_config.moderation.data)
		local leaderid = matches[2]
		if is_admin(msg) then
			data[tostring(msg.to.id)]['settings']['gp_leader'] = leaderid
			save_data(_config.moderation.data, data)
			return 'لیدر ثبت شد'
		elseif is_sudo(msg) then
			data[tostring(msg.to.id)]['settings']['gp_leader'] = leaderid
			save_data(_config.moderation.data, data)
			return 'لیدر ثبت شد'
		else
			return "فقط ادمین میتواند لیدر را انتخاب کند"
		end
	end

	if matches[1] == 'eaderdem' then
		local data = load_data(_config.moderation.data)
		if is_admin(msg) then
			data[tostring(msg.to.id)]['settings']['gp_leader'] = '0'
			save_data(_config.moderation.data, data)
			return 'لیدر برکنار شد'
		elseif is_sudo(msg) then
			data[tostring(msg.to.id)]['settings']['gp_leader'] = '0'
			save_data(_config.moderation.data, data)
			return 'لیدر برکنار شد'
		else
			return "فقط ادمین میتواند لیدر را برکنار کند"
		end
	end
	
	if matches[1] == 'odlist' then
		resultgp = msg
	    local data = load_data(_config.moderation.data)
		if not data[tostring(msg.to.id)] then
			return 'گروه بخش مديريت ندارد'
		end
		local gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
		if not gp_leader then
			gp_leader = 'گروه لیدر ندارد'
			return modlist(msg)
		elseif gp_leader == '0' then
			gp_leader = 'گروه لیدر ندارد'
			return modlist(msg)
		else
			local userid = 'user#id'..gp_leader
			local cbres_extra = {chatid = msg.to.id}
			return user_info(userid, callbackinfo, cbres_extra)
		end
	end
	
	if matches[1] == 'dminset' then
		if not is_sudo(msg) then
			return "فقط سودو ميتواند گلوبال ادمين انتخاب کند"
		end
		local member = string.gsub(matches[2], "@", "")
		chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
	end
	
	if matches[1] == 'dmindem' then
		if not is_sudo(msg) then
			return "فقط سودو ميتواند برکنار کند"
		end
		if string.match(matches[2], '^%d+$') then
			return admin_demote(receiver, "-----", matches[2])
		else
			local member = string.gsub(matches[2], "@", "")
			chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
		end
	end
	
	if matches[1] == 'dminlist' then
		return admin_list(msg)
	end
	
	if matches[1] == 'chat_add_user' and tonumber(msg.action.user.id) == tonumber(our_id) then
		block_user("user#id"..msg.from.id, cb_ok, false)
		chat_del_user('chat#id'..msg.to.id, 'user#id'..our_id, callback, false)
		return
	end
	
	if matches[1] == 'chat_created' then
		if tonumber(msg.from.id) == 0 then
			return automodadd(msg)
		else
			block_user("user#id"..msg.from.id, cb_ok, false)
			chat_del_user('chat#id'..msg.to.id, 'user#id'..our_id, callback, false)
		end
	end
end

return {
	description = "Robot and Group Moderation System", 
	usagehtm = '<tr><td align="center">adminlist</td><td align="right">لیست مدیران ارشد ربات که به اصطلاح گلوبال ادمین نامیده میشوند</td></tr>'
		..'<tr><td align="center">modlist</td><td align="right">لیست مدیران گروه</td></tr>'
		..'<tr><td align="center">leaderset آیدی</td><td align="right">افزودن سرگروه و لیدر. دقت کنید هر گروه فقط یک سرگروه میتواند داشته باشد و مدیران ربات فقط قادر به ثبت لیدر میباشند</td></tr>'
		..'<tr><td align="center">leaderdem</td><td align="right">حذف لیدر گروه</td></tr>'
		..'<tr><td align="center">modset یوزرنیم</td><td align="right">افزودن مدیر به لیست مدیران گروه. فقط لیدر میتواند</td></tr>'
		..'<tr><td align="center">moddem یوزرنیم</td><td align="right">برکنار کردن یک شخص از مدیریت گروه. فقط لیدر قادر است</td></tr>'
		..'<tr><td align="center">/reset</td><td align="right">دستوری مختص لیدرها که با آن میتوانند تمامی تنظیمات را به حالت اولیه بازگردانند همچنین تمام مدیران نیز برکنار خواهند شد</td></tr>',
--		..'<tr><td align="center">/modrem</td><td align="right">قسمت مدیریت یک گروه را حذف میکند</td></tr>'
--		..'<tr><td align="center">/modadd</td><td align="right">قسمت مدیریت یک گروه را مجدد فعال میکند</td></tr>',
	usage = {
		user = {
			"modlist : ليست مديران",
			"adminlist : ليست گلوبل ادمينها",
			},
		moderator = {
			"/reset : صفر کردن تنظیمات",
			"modset (@user) : افزودن مدير",
			"moddem (@user) : برکنار کردن",
			},
		admin = {
			"leaderset (id) : افزودن لیدر",
			"leaderdem : حذف لیدر",
			},
		sudo = {
			"/modadd : افزودن بخش مديريت",
			"/modrem : حذف بخش مديريت",
			"adminset (@user)",
			"admindem (@user)",
			},
		},
	patterns = {
		"^(/modadd)$",
		"^(/modrem)$",
		"^/(reset)$",
		"^[Ll](eaderset)$",
		"^[Ll](eaderset) (.*)$",
		"^[Ll](eaderdem)$",
		"^[Mm](odset) (.*)$",
		"^[Mm](oddem) (.*)$",
		"^[Mm](odlist)$",
		"^[Aa](dminset) (.*)$",
		"^[Aa](dmindem) (.*)$",
		"^[Aa](dminlist)$",
		"^!!tgservice (chat_add_user)$",
		"^!!tgservice (chat_created)$",
	}, 
	run = run,
}
end