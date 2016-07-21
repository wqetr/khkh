function plugin_enabled(name)
	for k,v in pairs(_config.enabled_plugins) do
		if name == v then
			return k
		end
	end
	return false
end

function plugin_exists(name)
	for k,v in pairs(plugins_names()) do
		if name..'.lua' == v then
			return true
		end
	end
	return false
end

local function list_all_plugins(only_enabled)
	local texts = ""
	local nsum = 0
	for k, v in pairs(plugins_names( )) do
		local status = '❌'
		nsum = nsum+1
		nact = 0
		for k2, v2 in pairs(_config.enabled_plugins) do
			if v == v2..'.lua' then 
				status = '✔' 
			end
			nact = nact+1
		end
		if not only_enabled or status == '✔' then
			v = string.match(v, "(.*)%.lua")
			texts = texts..nsum..'- '..status..' '..v..'\n'
		end
	end
	local texts = text.list..space..string.gsub(texts, "_", " ")..space..text.all..nsum..text.active..nact..text.disabl..nsum-nact
	return texts
end

local function reload_plugins( )
	plugins = {}
	load_plugins()
	return errorlog..text.loadmsg
end

local function enable_plugin(plugin_name)
	if plugin_enabled(plugin_name) then
		return plugin_name..text.isenable
	end
	if plugin_exists(plugin_name) then
		table.insert(_config.enabled_plugins, plugin_name)
		save_config()
		return reload_plugins( )
	else
		return plugin_name..text.notf
	end
end

local function disable_plugin(name, chat)
	if not plugin_exists(name) then
		return name..text.notf
	end
	local k = plugin_enabled(name)
	if not k then
		return name..text.notact
	end
	table.remove(_config.enabled_plugins, k)
	save_config( )
	return reload_plugins(true)    
end

local function disable_plugin_on_chat(receiver, plugin)
	if not plugin_exists(plugin) then
		return text.notf
	end
	if not _config.disabled_plugin_on_chat then
		_config.disabled_plugin_on_chat = {}
	end
	if not _config.disabled_plugin_on_chat[receiver] then
		_config.disabled_plugin_on_chat[receiver] = {}
	end
	_config.disabled_plugin_on_chat[receiver][plugin] = true
	save_config()
	return plugin..text.disabled
end

local function reenable_plugin_on_chat(receiver, plugin)
	if not _config.disabled_plugin_on_chat then
		return text.nfdp
	elseif not _config.disabled_plugin_on_chat[receiver] then
		return text.nfdp
	elseif not _config.disabled_plugin_on_chat[receiver][plugin] then
		return text.notact
	end
	_config.disabled_plugin_on_chat[receiver][plugin] = false
	save_config()
	return plugin..text.actived
end

local function dis_plugin_on_chat(receiver)
	if not _config.disabled_plugin_on_chat then
		return text.nfdp
	elseif not _config.disabled_plugin_on_chat[receiver] then
		return text.nfdp
	end
	local dp_tab = _config.disabled_plugin_on_chat[receiver]
	if #dp_tab == 0 then
		return text.digagfvn
	end
	local dp_list = ""
	for i=1,#dp_tab do
		dp_list = dp_list..i.."- "..dp_tab[i].."\n"
	end
	return text.listdgp..space..string.gsub(dp_list, "_", " ")..text.disabl..i
end

local function set_get_plugin(receiver, plugin, text)
	if text then
		local file = io.open("./plugins/"..plugin..".lua", "w")
		file:write(text)
		file:flush()
		file:close() 
		return text.savep
	else
		local file = io.open("./plugins/"..plugin..".lua")
		if file then
			send_document(receiver, "./plugins/"..plugin..".lua", ok_cb, false)
			return text.getp
		else
			return text.notf
		end
	end
end

local function run(msg, matches)
	grpup_language = (data[tostring(msg.to.id)]["settings"]["gp_language"] or "en")
	if grpup_language == "fa" then
		text = {
			list = "لیست ابزارهای ربات:",
			all = "مجموع ابزارها: ",
			active = " ابزارهای فعال: ",
			disabl = " ابزارهای غیر فعال: ",
			isenable = " فعال است ",
			notact = " فعال نیست ",
			notf = " پیدا نشد ",
			loadmsg = "بارگزاری ابزارها انجام شد",
			disabled = " در این گروه غیر فعال شد ",
			nfdp = " غیر قعال نیست ",
			dont = " فعال شد ",
			actived = "این ابزار غیر فعال نمیشود",
			digagfvn = "هیچ ابزار غیر فعالی در این گروه وجود ندارد",
			listdgp = "لیست ابزارهای غیر فعال گروه:",
			getp = "ابزار مورد نظر در چت خصوصی ارسال گشت",
			savep = "ابزار مورد نظر ذخیره شد",
			nftext = "در پیام مورد نظر متنی یافت نشد",
		}
	else
		text = {
			list = "List of robot plugins:",
			all = "All plugins: ",
			active = " enable plugins: ",
			disabl = " disable plugins: ",
			isenable = " is enable ",
			notact = " not enable ",
			notf = " not found ",
			loadmsg = "Plugins reloaded done...",
			disabled = " disabled in this group ",
			nfdp = " not disable ",
			dont = " actived ",
			actived = "You can't disable this plugin!",
			digagfvn = "This group haven't disable plugin.",
			listdgp = "This group disable plugins list:",
			getp = "Plugin sent to private chat",
			savep = "Plugin saved",
			nftext = "Not find text in selected message",
		}
	end
	if matches[3] then
		local plugin = string.gsub(matches[3]:lower(), " ", "_")
	end
	local receiver = get_receiver(msg)
	if matches[1]:lower() == 'plugs' and is_master(msg) then
		return list_all_plugins()
	elseif matches[1]:lower() == 'plug' and matches[2] == '+' and is_sudo(msg) then 
		return enable_plugin(plugin)
	elseif matches[1]:lower() == 'plug' and matches[2] == '+' and is_sudo(msg) then 
		if plugin == 'plugins' then return text.dont end
		return disable_plugin(plugin)
	elseif matches[1]:lower() == 'load' and is_sudo(msg) then 
		return reload_plugins(true)
	elseif matches[1]:lower() == "plug>" and is_sudo(msg) then
		local plugin = matches[2]:lower()
		local plugin = string.gsub(plugin, " ", "_")
		if matches[3] then
			text = matches[3]
		else
			text = false
		end
		if msg.reply_id then
			result = reply_info(msg)
			if result.text then
				text = result.text
			else
				return text.nftext
			end
		end
		return set_get_plugin(receiver, plugin, text)
	end
	if msg.to.type == "chat" then 
		if matches[1]:lower() == 'gp' and matches[2]:lower() == 'plugs' then
			return dis_plugin_on_chat(receiver)
		elseif matches[1]:lower() == 'gp' and matches[2] == '-' and is_momod(msg) then
			return disable_plugin_on_chat(receiver, plugin)
		elseif matches[1]:lower() == 'gp' and matches[2] == '+' and is_momod(msg) then
			return reenable_plugin_on_chat(receiver, plugin)
		end
	end
end

return {
	plug_name = "Plugins",
	plug_ver = "3.1",
	description = "Edit, manager and managment robot plugins",
	descriptionfa = "ویرایش و مدیریت ابزارهای ربات",
	-- 1=all 2=elders 3=moderator 4=leader 5=admins 6=master 7=sudo --- 1=pv 2=gp 3=pvgp 4=ch
	usagehtm = {
		{com = "plugs", des = "نمایش لیست پلاگینهای ربات", allow = "6", work = "3"},
		{com = "load", des = "بارگزاری مجدد پلاگین ها و اعمال تغییرات انجام شده در ابزارها", allow = "7", work = "3"},
		{com = "plug [+-] [name]", des = "فعال و غیر فعال کردن یک پلاگین. با - غیرفعال و با + فعال میشود", allow = "7", work = "3"},
		{com = "plug> [name] [none|text|reply]", des = "اگر این دستور فقط با نام پلاگین وارد شود. در صورت وجود، آن پلاگین در چت خصوصی ارسال میشود. اکر این دستور همراه یک نام روی یک پیام متنی رپلی شود، آن پیام متنی با نام مورد نظر به عنوان پلاگین ذخیره خواهد شد. اگر این دستور به همراه یک نام مو بعد از آن یک متن وارد شود، آن متن با نام مورد نظر به عنوان پلاگین ذخیره میگردد", allow = "7", work = "3"},
		{com = "gp [+-] [name]", des = "فعال یا غیر فعال کردن یک ابزار در گروه. اگر - وارد شود ابزار غیر فعال میشود و اگر + وارد شود ابزار فعال خواهد شد", allow = "3", work = "2"},
		{com = "gp plugs", des = "لیست ابزارهای غیر فعال گروه", allow = "2", work = "2"},
	},
	usage_en = {
		{com = "plugs", des = "plugins list", allow = "6", work = "3"},
		{com = "load", des = "reload plugs", allow = "7", work = "3"},
		{com = "plug [+-] [name]", des = "enable-disable plug", allow = "7", work = "3"},
		{com = "plug> [name]", des = "get plugin", allow = "7", work = "3"},
		{com = "plug> [name] [text|reply]", des = "set plugin", allow = "7", work = "3"},
		{com = "gp [+-] [name]", des = "enable-disable plug in gp", allow = "3", work = "2"},
		{com = "gp plugs", des = "gp disabled plugs", allow = "2", work = "2"},
	},
	usage_fa = {
		{com = "plugs", des = "ابزارهای ربات", allow = "6", work = "3"},
		{com = "load", des = "بارگزاری ابزارها", allow = "7", work = "3"},
		{com = "plug [+-] [name]", des = "فعال-غیرفعال کردن ابزار", allow = "7", work = "3"},
		{com = "plug> [name]", des = "دریافت ابزار", allow = "7", work = "3"},
		{com = "plug> [name] [text|reply]", des = "ویرایش-ثبت ابزار", allow = "7", work = "3"},
		{com = "gp [+-] [name]", des = "فعال-غیرفعال کردن ابزار در گروه", allow = "3", work = "2"},
		{com = "gp plugs", des = "ابزارهای غیرفعال گروه", allow = "2", work = "2"},
	},
	patterns = {
		"^(plugs)$",
		"^(load)$",
		"^(plug) ([+-]) ([%w_%.%-]+)$",
		"^(gp) (plugs)$",
		"^(gp) ([+-]) ([%w_%.%-]+)$",
		"^(plug>) ([^%s]+) (.*)",
		"^(plug>) ([^%s]+)$",
		},
	allow = elders,
--	cron = cron,
--	process = process,
	run = run
}