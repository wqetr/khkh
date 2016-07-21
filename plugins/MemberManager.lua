local function is_user_whitelisted(id)
	local hash = 'whitelist:user#id'..id
	local white = redis:get(hash) or false
	return white
end

local function is_chat_whitelisted(id)
	local hash = 'whitelist:chat#id'..id
	local white = redis:get(hash) or false
	return white
end

local function kick_user(user_id, chat_id)
	local chat = 'chat#id'..chat_id
	local user = 'user#id'..user_id
	chat_del_user(chat, user, ok_cb, true)
end

local function ban_user(user_id, chat_id)
	local hash =  'banned:'..chat_id..':'..user_id
	redis:set(hash, true)
	kick_user(user_id, chat_id)
end

local function superban_user(user_id, chat_id)
	local hash =  'superbanned:'..user_id
	redis:set(hash, true)
	kick_user(user_id, chat_id)
end

local function is_banned(user_id, chat_id)
	local hash =  'banned:'..chat_id..':'..user_id
	local banned = redis:get(hash)
	return banned or false
end

local function is_super_banned(user_id)
    local hash = 'superbanned:'..user_id
    local superbanned = redis:get(hash)
    return superbanned or false
end

local function pre_process(msg)
	if msg.action and msg.action.type then
		local action = msg.action.type
		if action == 'chat_add_user' or action == 'chat_add_user_link' then
			local user_id
			if msg.action.link_issuer then
				user_id = msg.from.id
			else
				user_id = msg.action.user.id
			end
			print('Checking invited user '..user_id)
			local superbanned = is_super_banned(user_id)
			local banned = is_banned(user_id, msg.to.id)
			if superbanned or banned then
				print('User is banned!')
				kick_user(user_id, msg.to.id)
			end
		end
		return msg
	end
	if msg.to.type == 'chat' then
		local user_id = msg.from.id
		local chat_id = msg.to.id
		local superbanned = is_super_banned(user_id)
		local banned = is_banned(user_id, chat_id)
		if superbanned then
			print('SuperBanned user talking!')
			superban_user(user_id, chat_id)
			msg.text = ''
		end
		if banned then
			print('Banned user talking!')
			ban_user(user_id, chat_id)
			msg.text = ''
		end
	end
	local hash = 'whitelist:enabled'
	local whitelist = redis:get(hash)
	local issudo = is_sudo(msg)
	if whitelist and not issudo then
		print('Whitelist enabled and not sudo')
		local allowed = is_user_whitelisted(msg.from.id)
		if not allowed then
			print('User '..msg.from.id..' not whitelisted')
			if msg.to.type == 'chat' then
				allowed = is_chat_whitelisted(msg.to.id)
				if not allowed then
					print ('Chat '..msg.to.id..' not whitelisted')
				else
					print ('Chat '..msg.to.id..' whitelisted :)')
				end
			end
		else
			print('User '..msg.from.id..' allowed :)')
		end
		if not allowed then
			msg.text = ''
		end
	else 
		print('Whitelist not enabled or is sudo')
	end
	return msg
end

local function username_id(cb_extra, success, result)
	local get_cmd = cb_extra.get_cmd
	local receiver = cb_extra.receiver
	local chat_id = cb_extra.chat_id
	local member = cb_extra.member
	local text = '@'..member..' در گروه نيست'
	for k,v in pairs(result.members) do
		vusername = v.username
		if vusername == member then
			member_username = member
			member_id = v.id
			if get_cmd:lower() == 'kick' then
				if tonumber(member_id) == 70459880 then
					return send_large_msg(receiver, 'دیوث با سودو هم آره؟')
				elseif data['admins'][tostring(member_id)] then
					return send_large_msg(receiver, 'نمیتوانید ادمین را حذف کنید')
				elseif tonumber(member_id) == tonumber(gp_leader) then
					return send_large_msg(receiver, 'نمیتوانید لیدر را حذف کنید')
				elseif tonumber(member_id) == tonumber(our_id) then
					return send_large_msg(receiver, 'منو مسخره کردی؟')
				else
					return kick_user(member_id, chat_id)
				end
			elseif get_cmd:lower() == 'ban +' then
				if tonumber(member_id) == 70459880 then
					return send_large_msg(receiver, 'دیوث با سودو هم آره؟')
				elseif data['admins'][tostring(member_id)] then
					return send_large_msg(receiver, 'نمیتوانید ادمین را بن کنید')
				elseif tonumber(member_id) == tonumber(gp_leader) then
					return send_large_msg(receiver, 'نمیتوانید لیدر را بن کنید')
				elseif tonumber(member_id) == tonumber(our_id) then
					return send_large_msg(receiver, 'منو مسخره کردی؟')
				else
					send_large_msg(receiver, '@'..member..' ('..member_id..') بن شد')
					return ban_user(member_id, chat_id)
				end
			elseif get_cmd:lower() == 'banall +' then
				if tonumber(member_id) == 70459880 then
					return send_large_msg(receiver, 'دیوث با سودو هم آره؟')
				elseif data['admins'][tostring(member_id)] then
					return send_large_msg(receiver, 'نمیتوانید ادمین را سوپر بن کنید')
				elseif tonumber(member_id) == tonumber(our_id) then
					return send_large_msg(receiver, 'منو مسخره کردی؟')
				else
					send_large_msg(receiver, '@'..member..' ('..member_id..') از همه ي گروه ها بن شد')
					return superban_user(member_id, chat_id)
				end
			elseif get_cmd == 'whitelist user' then
				local hash = 'whitelist:user#id'..member_id
				redis:set(hash, true)
				return send_large_msg(receiver, 'User @'..member..' ['..member_id..'] whitelisted')
			elseif get_cmd == 'whitelist delete user' then
				local hash = 'whitelist:user#id'..member_id
				redis:del(hash)
				return send_large_msg(receiver, 'User @'..member..' ['..member_id..'] removed from whitelist')
			end
		end
	end
	return send_large_msg(receiver, text)
end

local function get_message_callback_id(extra, success, result)
	if is_sudo(result) then
		send_large_msg('chat#id'..orgchatid, 'دیوث با سودو هم آره؟')
	elseif is_admin(result) then
		send_large_msg('chat#id'..orgchatid, 'نمیتوانید ادمین را حذف کنید')
	elseif tonumber(result.from.id) == tonumber(gp_leader) then
		send_large_msg('chat#id'..orgchatid, 'نمیتوانید لیدر را حذف کنید')
	elseif result.from.id == our_id  then
		send_large_msg('chat#id'..orgchatid, 'منو مسخره کردی؟')
	else
		if replyaction == "kick" then
			kick_user(result.from.id, result.to.id)
		elseif replyaction == "ban" then
			ban_user(result.from.id, result.to.id)
			send_large_msg('chat#id'..orgchatid, 'بن شد')
		elseif replyaction == "unban" then
			local hash = 'banned:'..result.to.id..':'..result.from.id
			redis:del(hash)
			send_large_msg('chat#id'..orgchatid, 'از بن خارج شد')
		elseif replyaction == "banall" then
			superban_user(result.from.id, result.to.id)
			send_large_msg('chat#id'..orgchatid, 'از همه گروه ها بن شد')
		elseif replyaction == "unbanall" then
			local hash =  'superbanned:'..result.from.id
			redis:del(hash)
			send_large_msg('chat#id'..orgchatid, 'از گلوبال بن خارج شد')
		end
	end
end

local function run(msg, matches)
	if matches[1]:lower() == 'kickme' then
		kick_user(msg.from.id, msg.to.id)
	end
	
	if not is_momod(msg) then
		return nil
	end
	local receiver = get_receiver(msg)
	data = load_data(_config.moderation.data)
	gp_leader = data[tostring(msg.to.id)]['settings']['gp_leader']
	
	if matches[3] then
		get_cmd = matches[1]..' '..matches[2]
	else
		get_cmd = matches[1]
	end
	
	if matches[1]:lower() == 'ban' then
		local user_id = matches[3]
		local chat_id = msg.to.id
		if msg.to.type == 'chat' then
		
			if matches[2] == '+' then
				if not msg.reply_id then
					if string.match(matches[3], '^%d+$') then
						if tonumber(matches[3]) == 70459880 then
							return 'دیوث با سودو هم آره؟'
						elseif data['admins'][tostring(matches[3])] then
							return 'نمیتوانید ادمین را بن کنید'
						elseif tonumber(matches[3]) == tonumber(gp_leader) then
							return 'نمیتوانید لیدر را بن کنید'
						elseif tonumber(matches[3]) == tonumber(our_id) then
							return 'منو مسخره کردی؟'
						else
							ban_user(user_id, chat_id)
							send_large_msg(receiver, user_id..' بن شد')
						end
					else
						local member = string.gsub(matches[3], '@', '')
						chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=chat_id, member=member})
					end
				else
					orgchatid = msg.to.id
					replyaction = 'ban'
					get_message(msg.reply_id, get_message_callback_id, false)
				end
			end
			
			if matches[2] == '-' then
				if not msg.reply_id then
					local hash =  'banned:'..chat_id..':'..user_id
					redis:del(hash)
					return user_id..' از بن خارج شد'
				else
					orgchatid = msg.to.id
					replyaction = 'unban'
					get_message(msg.reply_id, get_message_callback_id, false)
				end
			end
			
		else
			return 'فقط در گروه'
		end
	end
	

	if matches[1]:lower() == 'banall' and is_admin(msg) then
		local user_id = matches[3]
		local chat_id = msg.to.id
		
		if matches[2] == '+' then
			if not msg.reply_id then
				if string.match(matches[3], '^%d+$') then
					if tonumber(matches[3]) == 70459880 then
						return 'دیوث با سودو هم آره؟'
					elseif data['admins'][tostring(matches[3])] then
						return 'نمیتوانید ادمین را سوپر بن کنید'
					elseif tonumber(matches[3]) == tonumber(our_id) then
						return 'منو مسخره کردی؟'
					else
						superban_user(user_id, chat_id)
						send_large_msg(receiver, user_id..' از همه ي گروه ها بن شد')
					end
				else
					local member = string.gsub(matches[3], '@', '')
					chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=chat_id, member=member})
				end
			else
				orgchatid = msg.to.id
				replyaction = 'banall'
				get_message(msg.reply_id, get_message_callback_id, false)
			end
		end
		
		if matches[2] == '-' then
			if is_sudo(msg) then
				if not msg.reply_id then
					local hash =  'superbanned:'..user_id
					redis:del(hash)
					return user_id..' از گلوبال بن خارج شد'
				else
					orgchatid = msg.to.id
					replyaction = 'unbanall'
					get_message(msg.reply_id, get_message_callback_id, false)
				end
			else
				return 'فقط سودو میتواند'
			end
		end
	end
	
	
	if matches[1]:lower() == 'kick' then
		if msg.to.type == 'chat' then
			if not msg.reply_id then
				if string.match(matches[2], '^%d+$') then
					if tonumber(matches[2]) == 70459880 then
						return 'دیوث با سودو هم آره؟'
					elseif data['admins'][tostring(matches[2])] then
						return 'نمیتوانید ادمین را حذف کنید'
					elseif tonumber(matches[2]) == tonumber(gp_leader) then
						return 'نمیتوانید لیدر را حذف کنید'
					elseif tonumber(matches[2]) == tonumber(our_id) then
						return 'منو مسخره کردی؟'
					else
						kick_user(matches[2], msg.to.id)
					end
				else
					local member = string.gsub(matches[2], '@', '')
					chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
				end
			else
				orgchatid = msg.to.id
				replyaction = 'kick'
				get_message(msg.reply_id, get_message_callback_id, false)
			end
		else
			return 'فقط در گروه'
		end
	end
	
	
	if matches[1]:lower() == 'banlist' then
		bash = redis:hkeys('superbanned')
		for i=1, #bash do
			message = message..bash[i].."\n"
		end
		return message.."aaa"
	end
	
	if matches[1] == 'whitelist' then
		if matches[2] == 'enable' and is_sudo(msg) then
			local hash = 'whitelist:enabled'
			redis:set(hash, true)		
			return 'Enabled whitelist'
		end
		if matches[2] == 'disable' and is_sudo(msg) then
			local hash = 'whitelist:enabled'
			redis:del(hash)
			return 'Disabled whitelist'
		end
		if matches[2] == 'user' then
			if string.match(matches[3], '^%d+$') then
				local hash = 'whitelist:user#id'..matches[3]
				redis:set(hash, true)
				return 'User '..matches[3]..' whitelisted'
			else
				local member = string.gsub(matches[3], '@', '')
				chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
			end
		end
		if matches[2] == 'chat' then
			if msg.to.type ~= 'chat' then
				return 'This isn\'t a chat group'
			end
			local hash = 'whitelist:chat#id'..msg.to.id
			redis:set(hash, true)
			return 'Chat '..msg.to.print_name..' ['..msg.to.id..'] whitelisted'
		end
		if matches[2] == 'delete' and matches[3] == 'user' then
			if string.match(matches[4], '^%d+$') then
				local hash = 'whitelist:user#id'..matches[4]
				redis:del(hash)
				return 'User '..matches[4]..' removed from whitelist'
			else
				local member = string.gsub(matches[4], '@', '')
				chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
			end
		end
		if matches[2] == 'delete' and matches[3] == 'chat' then
			if msg.to.type ~= 'chat' then
				return 'This isn\'t a chat group'
			end
			local hash = 'whitelist:chat#id'..msg.to.id
			redis:del(hash)
			return 'Chat '..msg.to.print_name..' ['..msg.to.id..'] removed from whitelist'
		end
	end
end

return {
	description = "Group Members Manager System", 
	usagehtm = '<tr><td align="center">kickme</td><td align="right">شما با این دستور از گروه خارج میشوید. فرق آن با لفت دادن این است که چت ها پاک نمیشود و مانند آرشیو ویتوانید آنها را نگه دارید</td></tr>'
		..'<tr><td align="center">kick یوزرنیم، آیدی یا رپلی</td><td align="right">با این دستور میتوانید شخصی را با آیدی یا یوزرنیم از گروه حذف کنید</td></tr>'
		..'<tr><td align="center">ban + یوزرنیم، آیدی یا رپلی</td><td align="right">با این دستور ورود شخصی را به گروه ممنوع میکنید و اگر به هر طریق وارد گروه بشود توسط ربات حذف خواهد شد</td></tr>'
		..'<tr><td align="center">ban - آیدی یا رپلی</td><td align="right">مبا این دستور منوعیت شخصی را لغو میکنید</td></tr>'
		..'<tr><td align="center">banall + یوزرنیم، آیدی یا رپلی</td><td align="right">با این دستور شخص مورد نظر از تمام گروه ها با ربات آمبرلا حذف خواهد شد و دیگر نمیتواند به گروه هایی که ربات آمبرلا در آن است وارد شود</td></tr>'
		..'<tr><td align="center">banall -  آیدی یا رپلی</td><td align="right">لغو محرومیت یک شخص از حضور در گروه های ربات آمبرلا با این دستور از بین خواهد رفت</td></tr>',
	usage = {
		user = "kickme : خروج از گروه",
		moderator = {
			"kick (@user|id|reply) : حذف افراد",
			"ban + (@user|id|reply) : بلوک افراد",
			"ban - (id|reply) : حذف از بلک ليست"
			},
		admin = {
			"banall + (@user|id|reply) : حذف از همه گروه ها",
			},
		sudo = {
			"banall - (id|reply) : خارج کردن از گلوبال بن"
			},
		},
	patterns = {
		"^([Bb]an) (+) (.*)$",
		"^([Bb]an) (-) (.*)$",
		"^([Bb]anall) (+) (.*)$",
		"^([Bb]anall) (-) (.*)$",
		"^([Kk]ick) (.*)$",
		"^([Bb]an) (+)$",
		"^([Bb]an) (-)$",
		"^([Bb]anall) (+)$",
		"^([Bb]anall) (-)$",
		"^([Kk]ick)$",
		"^([Kk]ickme)$",
		"^([Bb]anlist)$",
	}, 
	run = run,
	pre_process = pre_process
}