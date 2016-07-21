do
local function create_group(msg)
    if not is_sudo(msg) then
        return "ساخت گروه آنلاین میباشد، به آدرس زیر مراجعه کنید\nhttp://umbrella.shayan-soft.ir/newgp\n\nsudo: @shayansoft"
    end
    local group_creator = msg.from.print_name
    create_group_chat (group_creator, group_name, ok_cb, false)
    return 'گروه '..string.gsub(group_name, '_', ' ')..' ساخته شد، پيامها را بررسي کنيد '
end
 
local function set_description(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local data_cat = 'description'
    data[tostring(msg.to.id)][data_cat] = deskripsi
    save_data(_config.moderation.data, data)
    return 'اين پيام به عنوان توضيخات ثبت شد:\n______________________________\n'..deskripsi
end
 
local function get_description(msg, data)
    local data_cat = 'description'
    if not data[tostring(msg.to.id)][data_cat] then
        return 'گروه توضيحات ندارد'
    end
    local about = data[tostring(msg.to.id)][data_cat]
    return 'درباره ی گروه:\n______________________________\n'..about
end
 
local function set_rules(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local data_cat = 'rules'
    data[tostring(msg.to.id)][data_cat] = rules
    save_data(_config.moderation.data, data)
    return 'اين قوانين ثبت شدند:\n_______________________________\n'..rules
end
 
local function get_rules(msg, data)
    local data_cat = 'rules'
    if not data[tostring(msg.to.id)][data_cat] then
        return 'گروه قوانين ندارد'
    end
    local rules = data[tostring(msg.to.id)][data_cat]
    return 'قوانین گروه:\n______________________________\n'..rules
end
 
local function lock_group_name(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
    local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
    if group_name_lock == 'yes' then
		return 'نام گروه قفل است'
    else
		data[tostring(msg.to.id)]['settings']['lock_name'] = 'yes'
		save_data(_config.moderation.data, data)
        data[tostring(msg.to.id)]['settings']['set_name'] = string.gsub(msg.to.print_name, '_', ' ')
        save_data(_config.moderation.data, data)
        return 'نام گروه قفل شد'
    end
end
 
local function unlock_group_name(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
    local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
    if group_name_lock == 'no' then
        return 'نام گروه باز است'
    else
        data[tostring(msg.to.id)]['settings']['lock_name'] = 'no'
        save_data(_config.moderation.data, data)
		return 'نام گروه باز شد'
    end
end
 
local function lock_group_member(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
    if group_member_lock == 'yes' then
        return 'عضوگيري بسته است'
    else
        data[tostring(msg.to.id)]['settings']['lock_member'] = 'yes'
        save_data(_config.moderation.data, data)
		return 'عضوگيري بسته شد'
    end
end
 
local function unlock_group_member(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
    if group_member_lock == 'no' then
        return 'عضوگيري باز است'
    else
        data[tostring(msg.to.id)]['settings']['lock_member'] = 'no'
        save_data(_config.moderation.data, data)
		return 'عضوگيري باز شد'
    end
end
 
local function lock_group_photo(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
    if group_photo_lock == 'yes' then
        return 'عکس گروه قفل است'
    else
        data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
        save_data(_config.moderation.data, data)
		return 'عکس گروه را مجدد ارسال کنيد'
	end
end
 
local function unlock_group_photo(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
    if group_photo_lock == 'no' then
        return 'عکس گروه باز است'
    else
        data[tostring(msg.to.id)]['settings']['lock_photo'] = 'no'
        save_data(_config.moderation.data, data)
		return 'قفل عکس گروه باز شد'
    end
end
 
local function set_group_photo(msg, success, result)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
	if success then
		local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
		os.rename(result, file)
		chat_set_photo(receiver, file, ok_cb, false)
		data[tostring(msg.to.id)]['settings']['set_photo'] = file
		save_data(_config.moderation.data, data)
		data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
		save_data(_config.moderation.data, data)
		send_large_msg(receiver, 'عکس گروه ذخیره شد', ok_cb, false)
	else
		send_large_msg(receiver, 'انجام نشد!', ok_cb, false)
	end
end

local function show_group_settings(msg, data)
    if not is_momod(msg) then
        return "شما مدير نيستيد"
    end
    local settings = data[tostring(msg.to.id)]['settings']
	if not settings.gp_user then
		settings.gp_user = "-----"
	end
    local text = 'تنظيمات گروه:\n_________________________\n'
        .."> قفل نام گروه : "..settings.lock_name.."\n"
        .."> قفل عکس گروه : "..settings.lock_photo.."\n"
        .."> قفل عضوگيري گروه : "..settings.lock_member.."\n"
		.."> قفل افزودن ربات : "..settings.lock_bot.."\n"
		.."> قفل ارسال لینک : "..settings.lock_link.."\n"
		.."> قفل ارسال استیکر : "..settings.lock_sticker.."\n"
        .."> مقابله با اسپم : "..settings.lock_spam.."\n"
        .."> عمل آنتي اسپم : kick\n"
        .."> حساسيت آنتي اسپم : f."..settings.spam_action.."\n"
		.."> فیلترینگ کلمات : "..settings.lock_filter.."\n"
		.."> قابلیت چت با آمبرلا : "..settings.gp_chatter.."\n"
		.."> پیام خوش آمدگویی : "..settings.gp_welcome.."\n"
		.."> مدل گروه منیجر : "..settings.gp_model.."\n"
		.."> زبان ربات : "..settings.gp_language.."\n"
		.."> یوزرنیم گروه : "..settings.gp_user.."\n"
        .."> ورژن ربات : v2.0\n"
		.." Umbrella Bot @UmbrellaTeam"
    return text
end

local function pre_process(msg)
	if not msg.text and msg.media then
		msg.text = '['..msg.media.type..']'
	end
	return msg
end

function run(msg, matches)
    if matches[1] == 'makegp' and matches[2] then
        group_name = matches[2]
        return create_group(msg)
    end
	
    if not is_chat_msg(msg) then
        return "فقط در گروه"
    end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	
    if msg.media and is_chat_msg(msg) and is_momod(msg) then
        if msg.media.type == 'photo' and data[tostring(msg.to.id)] then
            if data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' then
                load_photo(msg.id, set_group_photo, msg)
            end
        end
    end
	
    if data[tostring(msg.to.id)] then
        local settings = data[tostring(msg.to.id)]['settings']
        if matches[1] == 'about' and matches[2] then
            deskripsi = matches[2]
            return set_description(msg, data)
        end
        if matches[1] == 'bout' then
            return get_description(msg, data)
        end
        if matches[1] == 'rules' then
            rules = matches[2]
            return set_rules(msg, data)
        end
        if matches[1] == 'ules' then
            return get_rules(msg, data)
        end
        if matches[1] == 'p' and matches[2] == '+' then
			if matches[3] == 'name' then
				return lock_group_name(msg, data)
			end
            if matches[3] == 'member' then
                return lock_group_member(msg, data)
            end
                if matches[3] == 'pic' then
				return lock_group_photo(msg, data)
            end
        end
        if matches[1] == 'p' and matches[2] == '-' then
            if matches[3] == 'name' then
                return unlock_group_name(msg, data)
            end
            if matches[3] == 'member' then
                return unlock_group_member(msg, data)
            end
            if matches[3] == 'pic' then
                return unlock_group_photo(msg, data)
            end
        end
        if matches[1] == 'p' and matches[2] == '?' then
            return show_group_settings(msg, data)
        end
        if matches[1] == 'chat_rename' then
            if not msg.service then
                return "منو مسخره کردی؟"
            end
			local group_name_set = settings.set_name
			local group_name_lock = settings.lock_name
			local to_rename = 'chat#id'..msg.to.id
            if group_name_lock == 'yes' then
                if group_name_set ~= tostring(msg.to.print_name) then
                    rename_chat(to_rename, group_name_set, ok_cb, false)
                end
            elseif group_name_lock == 'no' then
				return nil
            end
        end
        if matches[1] == 'name' and is_momod(msg) then
            local new_name = string.gsub(matches[2], '_', ' ')
            data[tostring(msg.to.id)]['settings']['set_name'] = new_name
            save_data(_config.moderation.data, data)
            local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
            local to_rename = 'chat#id'..msg.to.id
            rename_chat(to_rename, group_name_set, ok_cb, false)
        end
        if matches[1] == 'pic' and is_momod(msg) then
            data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			return 'عکس گروه را ارسال نماييد'
		end
		if matches[1] == 'chat_add_user' then
			if not msg.service then
				return "منو مسخره کردی؟"
			end
			if tonumber(msg.action.user.id) == 70459880 then
				return nil
			elseif data['admins'][tostring(msg.action.user.id)] then
				return nil
			end
			local group_member_lock = settings.lock_member
			local user = 'user#id'..msg.action.user.id
			local chat = 'chat#id'..msg.to.id
			if group_member_lock == 'yes' then
				chat_del_user(chat, user, ok_cb, true)
			elseif group_member_lock == 'no' then
				return nil
			end	
		end
		if matches[1] == 'chat_delete_photo' then
			if not msg.service then
				return "منو مسخره کردی؟"
			end
			local group_photo_lock = settings.lock_photo
			if group_photo_lock == 'yes' then
				chat_set_photo (receiver, settings.set_photo, ok_cb, false)
			elseif group_photo_lock == 'no' then
				return nil
			end
		end
		if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
			if not msg.service then
				return "منو مسخره کردی؟"
			end
			local group_photo_lock = settings.lock_photo
			if group_photo_lock == 'yes' then
				chat_set_photo (receiver, settings.set_photo, ok_cb, false)
			elseif group_photo_lock == 'no' then
				return nil
			end
		end
	end
end
 
return {
	description = "Group Manager System",
	usagehtm = '<tr><td align="center">about</td><td align="right">مشاهده ی توضیحات گروه</td></tr>'
		..'<tr><td align="center">rules</td><td align="right">مشاهده ی قوانین گروه</td></tr>'
		..'<tr><td align="center">/about متن</td><td align="right">ثبت متنی به عنوان توضیحات گروه</td></tr>'
		..'<tr><td align="center">/rules متن</td><td align="right">ثبت متنی به عنوان قوانین گروه</td></tr>'
		..'<tr><td align="center">/name نام</td><td align="right">ثبت نام گروه</td></tr>'
		..'<tr><td align="center">/pic</td><td align="right">ثبت نام گروه</td></tr>'
		..'<tr><td align="center">gp + name</td><td align="right">قفل کردن نام گروه به طوری که دیگر کسی نمیتواند آن را تغییر دهد</td></tr>'
		..'<tr><td align="center">gp - name</td><td align="right">باز کردن قفل نام گروه</td></tr>'
		..'<tr><td align="center">gp + member</td><td align="right">قفل کردن عضوگیری گروه به طوری که هیچ کس نمیتواند وارد گروه شود</td></tr>'
		..'<tr><td align="center">gp - member</td><td align="right">لغو قفل عضوگیری</td></tr>'
		..'<tr><td align="center">gp + pic</td><td align="right">قفل عکس گروه. از این پس اگر کسی عکس گروه را تغییر دهد یا آن را حذف کند، ربات مجدد آن را به حالت قبل برگردان میکند</td></tr>'
		..'<tr><td align="center">gp - pic</td><td align="right">قفل عکس را باز میکند</td></tr>'
		..'<tr><td align="center">gp + bot</td><td align="right">عضوگیری ربات ها را غیر مجاز میکند</td></tr>'
		..'<tr><td align="center">gp - bot</td><td align="right">بعد از اعمال این دستور میتوانید به گروه ربات اضافه کنید</td></tr>'
		..'<tr><td align="center">gp + link</td><td align="right">ارسال لینک در گروه را غیر مجاز میکند و در صورتی که توسط شخص عادی در گروه لینک ارسال شود، فرد حذف خواهد شد</td></tr>'
		..'<tr><td align="center">gp - link</td><td align="right">ارسال لینک ها مجاز خواهد بود</td></tr>'
		..'<tr><td align="center">gp ?</td><td align="right">نمایش تنظیمات و مشخصات گروه</td></tr>',
	usage = {
		user = {
			"/makegp (name) : ساخت گروه",
			"about : توضيحات",
			"rules : قوانين",
		},
		moderator = {
			"/name (name) : ثبت نام گروه",
			"/about (message) : ثبت توضيحات",
			"/rules (message) : ثبت قوانين",
			"/pic : ثبت عکس گروه",
			"gp +|- name : قفل نام گروه",
			"gp +|- member : قفل عضوگيري",
			"gp +|- pic : قفل عکس گروه",
			"gp +|- bot : قفل عضوگیری ربات",
			"gp +|- link : قفل ارسال لینک",
			"gp ? : نمايش تنظيمات"
		},
	},
	patterns = {
		"^/(makegp) (.*)$",
		"^/(about) (.*)$",
		"^[Aa](bout)$",
		"^/(rules) (.*)$",
		"^[Rr](ules)$",
		"^/(name) (.*)$",
		"^/(pic)$",
		"^[Gg](p) (+) (.*)$",
		"^[Gg](p) (-) (.*)$",
		"^[Gg](p) (?)$",
		"^!!tgservice (.+)$",
		"%[(photo)%]",
	},
	run = run,
	--hide = true,
	pre_process = pre_process
} 
end