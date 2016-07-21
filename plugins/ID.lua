local function user_print_name(user)
	if user.print_name then
		return user.print_name
	end
	local text = ''
	if user.first_name then
		text = user.last_name..' '
	end
	if user.lastname then
		text = text..user.last_name
	end
	return text
end

local function returnids(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local chat_id = result.id
	local chatname = result.print_name
	local text = 'گروه: '..chatname..' آي دي: '..chat_id..' جمعيت: '..result.members_num..'\n______________________________\n'
		i = 0
	for k,v in pairs(result.members) do
		i = i+1
		if v.print_name == nil then
			i = i-1
		else
			text = text .. i .. "> " .. string.gsub(v.print_name, "_", " ") .. " (" .. v.id .. ")\n"
		end
	end
	send_large_msg(receiver, text)
end

local function returnidshtm(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local chat_id = result.id
	local chatname = result.print_name
	local text = '<html><head><title>Umbrella Bot</title></head><body>'
	..'<center><font size=5 face=tahoma color=#ff0000><b>Umbrella Bot - IDs Log Pro</b></font><br>'
	..'<font size=3 face=tahoma color=#000000>'
	..'Group Name: <b>'..chatname..'</b><br>Group ID: <b>'..chat_id..'</b><br>People: <b>'..result.members_num..'</b></font><br><br>'
	..'<center><font size=2 face=tahoma color=#000000><table width=500 border=1 cellSpacing=1 cellPadding=1><tr>'
	..'<td width="7%" align="center" valign="middle"><b>Num</b></b></td>'
	..'<td width="50%" align="center" valign="middle"><b>Name</b></td>'
	..'<td width="25%" align="center" valign="middle"><b>Username</b></td>'
	..'<td width="18%" align="center" valign="middle"><b>ID</b></td></tr>'
	i = 0
	for k,v in pairs(result.members) do
		i = i+1
		if not v.username then
			usernameid = '-----'
		else
			usernameid = '@'..v.username
		end
		if v.print_name == nil then
			i = i-1
		else
			text = text..'<tr><td align="center">'..i..'</td><td>'..string.gsub(v.print_name, "_", " ")..'</td><td align="center">'..usernameid..'</td><td align="center">'..v.id..'</td></tr>'
		end
	end
	local text = text..'</table><br><br></font><font size=3 face=tahoma><b><a href="http://umbrella.shayan-soft.ir" target="_blank">www.Umbrella.shayan-soft.ir</a></b></center></font><br></body></html>'
	local file = io.open("./file/IDs.htm", "w")
	file:write(text)
	file:flush()
	file:close() 
	send_document(receiver,"./file/IDs.htm", ok_cb, false)
	return
end

local function returnidstxt(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local chat_id = result.id
	local chatname = result.print_name
	local text = 'گروه: '..chatname..' آي دي: '..chat_id..' جمعيت: '..result.members_num..'\n______________________________\n'
	i = 0
	for k,v in pairs(result.members) do
		i = i+1
		if v.print_name == nil then
			i = i-1
		else
			text = text .. i .. "> " .. string.gsub(v.print_name, "_", " ") .. " (" .. v.id .. ")\n"
		end
	end
	local file = io.open("./file/IDs.txt", "w")
	file:write(text)
	file:flush()
	file:close() 
	send_document(receiver,"./file/IDs.txt", ok_cb, false)
end

local function username_id(cb_extra, success, result)
	local receiver = cb_extra.receiver
	local qusername = cb_extra.qusername
	local text = 'پارامتر براي شما مجاز نيست يا اشتباه است'
	for k,v in pairs(result.members) do
		vusername = v.username
		if vusername == qusername then
			text = 'يوزر: @'..vusername..' \nآي دي: '..v.id
		end
	end
	send_large_msg(receiver, text)
end

local function callbackres(extra, success, result)
	local chat = 'chat#id'..extra.chatid
	send_large_msg(chat, result.id)
end

local function callbackinfo(extra, success, result)
	local chat = 'chat#id'..extra.chatid
	local moshakhasat = 'Name: '..result.print_name..'\nUser: @'..(result.username or '-----')
	send_large_msg(chat, moshakhasat)
end

local function get_message_callback_id(extra, success, result)
	local chat = 'chat#id'..result.to.id
	send_large_msg(chat, result.from.id)
end

local function run(msg, matches)
	local receiver = get_receiver(msg)
	
	if msg.reply_id then
		return get_message(msg.reply_id, get_message_callback_id, false)
	end
	
	if matches[1] == "d" then
		local text = msg.from.id
		return text
	  
	elseif matches[1] == "me" then
		local text = msg.from.id
		return text
	  
	elseif matches[1] == "gp" then
		local text = ''
		if is_chat_msg(msg) then
			text = msg.to.id
		end
		return text
	  
	elseif matches[1] == "all" and is_momod(msg) then
		if not is_chat_msg(msg) then
			return "فقط در گروه"
		end
		local chat = 'chat#id'..msg.to.id
		return chat_info(chat, returnids, {receiver=receiver})
	  
	elseif matches[1] == "all>" and is_momod(msg) then
		if not is_chat_msg(msg) then
			return "فقط در گروه"
		end
		local chat = 'chat#id'..msg.to.id
		return chat_info(chat, returnidstxt, {receiver=receiver})
	  
	elseif matches[1] == "/id all>" and is_momod(msg) then
		if not is_chat_msg(msg) then
			return "فقط در گروه"
		end
		local chat = 'chat#id'..msg.to.id
		return chat_info(chat, returnidshtm, {receiver=receiver})
	  
	elseif matches[1] == "&id all" and is_admin(msg) then
		local chat = 'chat#id'..matches[2]
		return chat_info(chat, returnids, {receiver=receiver})
	  
	elseif matches[1] == "&id all>" and is_admin(msg) then
		local chat = 'chat#id'..matches[2]
		return chat_info(chat, returnidstxt, {receiver=receiver})
	  
	elseif matches[1] == "&/id all>" and is_admin(msg) then
		local chat = 'chat#id'..matches[2]
		return chat_info(chat, returnidshtm, {receiver=receiver})
	
	else
		if string.match(matches[1], '^%d+$') then
			local userid = 'user#id'..matches[1]
			local cbres_extra = {chatid = msg.to.id}
			return user_info(userid, callbackinfo, cbres_extra)
		else
			local username = matches[1]
			local username = username:gsub("@","")
			local cbres_extra = {chatid = msg.to.id}
			return res_user(username, callbackres, cbres_extra)
		end
	end
end

return {
	description = "User ID Number and Group ID Number Info",
	usagehtm = '<tr><td align="center">id me</td><td align="right">آی دی شما را نشان میدهد. آی دی شما همان شماره پرونده ی شما در شرکت تلگرام است که به طور عادی قادر به دیدن آن نیستید</td></tr>'
	..'<tr><td align="center">id gp</td><td align="right">آی دی گروه را به شما نشان میدهد. این آی دی شماره پرونده ی این گروه بر روی سرور تلگرام است</td></tr>'
	..'<tr><td align="center">id یوزرنیم</td><td align="right">آی دی شخصی را از روی یوزرنیم آن شخص استخراج کرده و به شما نشان میدهد. دقت کنید این شخص حتا باید در گروه باشد</td></tr>'
	..'<tr><td align="center">id رپلی</td><td align="right">آی دی شخص ارسال کننده ی پیام را نشان میدهد</td></tr>'
	..'<tr><td align="center">id آیدی</td><td align="right">نام و در صورت وجود، یوزرنیم آی دی وارد شده را نشان میدهد</td></tr>'
	..'<tr><td align="center">id all</td><td align="right">آی دی تمام اعضای گروه را در قالب متن برای شما ارسال میکند</td></tr>'
	..'<tr><td align="center">id all></td><td align="right">آی دی تمام اعضای گروه را در قالب فایل متنی برای شما ارسال میکند</td></tr>'
	..'<tr><td align="center">/id all></td><td align="right">آی دی تمام اعضای گروه را در قالبی بسیار حرفه ای و بی سابقه در جهان و به صورت فایل اچ تی ام ال ارسال میکند</td></tr>',
	usage = {
		user = {
			"id me : آي دي شما",
			"id gp : آي دي گروه",
			"id (@user|reply) : اي دي يک يوزر",
			"id (id) : مشخصات آی دی",
		},
		moderator = {
			"id all : اي دي اعضا",
			"id all> : لوگ آي دي اعضا",
			"/id all> : لوگ حرفه ای آي دي اعضا",
		},
	},
	patterns = {
		"^(&id all) (%d+)$",
		"^(&id all>) (%d+)$",
		"^(&/id all>) (%d+)$",
		"^(/id all>)$",
		"^[Ii](d)$",
		"^[Ii]d$",
		"^[Ii]d (.*)$",
	},
	run = run
}