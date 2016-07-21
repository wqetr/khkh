do 
function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0
	local iter = function ()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

local function has_usage_data(dict)
	if (dict.usage == nil or dict.usage == '') then
		return false
	end
	return true
end

local function plugin_help(name,number,requester)
	local plugin = ""
	if number then
		local i = 0
		for name in pairsByKeys(plugins) do
			if plugins[name].hidden then
				name = nil
			else
				i = i + 1
				if i == tonumber(number) then
					plugin = plugins[name]
				end
			end
		end
	else
		plugin = plugins[name]
		if not plugin then
			return nil
		end
	end
    local text = ""
    if (type(plugin.usage) == "table") then
		for ku,usage in pairs(plugin.usage) do
			if ku == 'user' then -- usage for user
				if (type(plugin.usage.user) == "table") then
					for k,v in pairs(plugin.usage.user) do
						text = text..v..'\n'
					end
				elseif has_usage_data(plugin) then -- Is not empty
					text = text..plugin.usage.user..'\n'
				end
			elseif ku == 'moderator' then -- usage for moderator
				if requester == 'moderator' or requester == 'admin' or requester == 'sudo' then
					if (type(plugin.usage.moderator) == "table") then
						for k,v in pairs(plugin.usage.moderator) do
							text = text..v..'\n'
						end
					elseif has_usage_data(plugin) then -- Is not empty
						text = text..plugin.usage.moderator..'\n'
					end
				end
			elseif ku == 'admin' then -- usage for admin
				if requester == 'admin' or requester == 'sudo' then
					if (type(plugin.usage.admin) == "table") then
						for k,v in pairs(plugin.usage.admin) do
							text = text..v..'\n'
						end
					elseif has_usage_data(plugin) then -- Is not empty
						text = text..plugin.usage.admin..'\n'
					end
				end
			elseif ku == 'sudo' then -- usage for sudo
				if requester == 'sudo' then
					if (type(plugin.usage.sudo) == "table") then
						for k,v in pairs(plugin.usage.sudo) do
							text = text..v..'\n'
						end
					elseif has_usage_data(plugin) then -- Is not empty
						text = text..plugin.usage.sudo..'\n'
					end
				end
			else
				text = text..usage..'\n'
			end
		end
		text = text..'----\n'
	elseif has_usage_data(plugin) then -- Is not empty
		text = text..plugin.usage..'\n----\n'
    end
    return text
end

local function telegram_help()
	local i = 0
	local text = "ليست ابزارهاي آمبرلا:\n______________________________\n"
	for name in pairsByKeys(plugins) do
		if plugins[name].hidden then
			name = nil
		else
			i = i + 1
			text = text..i..'> '..name..'\n'
		end
	end
	return text
end

local function help_all(requester)
	local ret = ""
	for name in pairsByKeys(plugins) do
		if plugins[name].hidden then
			name = nil
		else
			ret = ret .. plugin_help(name, nil, requester)
		end
	end
	return ret
end

local function smal_help()
	return [[راهنمای ربات آمبرلا:
	______________________________
	1- دستورات بدون علامت میباشد
	
	2- لیست دستورات برای مقام های مختلف متفاوت است و هر کس به نسبت اختیاراتش میتواند کامندها را ببیند
	
	3- برای دیدن لیست کامندها help/ بزنید
	
	4- برای دیدن راهنمای جامع <help/ بزنید
	
	5- برای دیدن لیست ابزارها helps را ارسال کنید
	
	6- برای دیدن کامندهای هر ابزار، پس از دستور helps عدد یا نام ابزار را وارد کنید
	
	7- برای دیدن مشخصات ربات از ver استفاده کنید
	
	8- برای دیدن لینک ساپورت، مدت زمان آماده به کار ربات، ادمینها، سازنده، مشخصات سرور و... دستور umbrella را ارسال فرمایید
	
	9- ربات رپورت است، برای استفاده از همه ی قابلیتهای آن 10 پیام به پی وی ارسال کنید
	
	10- در لیست کامندها (دستورات) محتویات داخل پرانتز، متغییرها هستند و نباید موقع ارسال دستور نیز از پرانتز استفاده کنید
	______________________________
	Web: www.Umbrella.shayan-soft.ir
	Channel: @UmbrellaTeam
	Sudo Admin: @shayansoft]]
end

local function run(msg, matches)
	if is_sudo(msg) then
		requester = "sudo"
	elseif is_admin(msg) then
		requester = "admin"
	elseif is_momod(msg) then
		requester = "moderator"
	else
		requester = "user"
	end
	if matches[1] == "elp" then
		return smal_help()
	elseif matches[1] == "elps" then
		return telegram_help()
	elseif matches[1] == "/help" then
		return help_all(requester)
	else
		local text = ""
		if tonumber(matches[1])  then
			text = plugin_help(nil, matches[1], requester)
		else
			text = plugin_help(matches[1], nil, requester)
		end
		if not text then
			text = telegram_help()
		end
		return text
	end
end
 
return {
	description = "Help For Tools and Commands",
	usagehtm = '<tr><td align="center">help</td><td align="right">نمایش راهنمای ربات</td></tr>'
	..'<tr><td align="center">helps</td><td align="right">لیست ابزار ها را همراه عددشان نمایش میدهد</td></tr>'
	..'<tr><td align="center">helps عدد یا نام ابزار</td><td align="right">دستورات یک ابزار را همراه توضیحات مختصر نمایش میدهد</td></tr>'
	..'<tr><td align="center">/help</td><td align="right">لیست تمام دستورات را همراه توضیحات مختصر نشان میدهد. گاهی ممکن است متن ارائه شده به شما ناقص باشد و این به دلیل باگ موجود در تلگرام است</td></tr>'
	..'<tr><td align="center">/help></td><td align="right">راهنمای دستورات را به شکل تشریحی در اختیارتان قرار میدهد</td></tr>',
	usage = {
		"help : راهنما",
		"helps : ليست ابزارها",
		"helps (name|num) : توضيح دستور",
		"/help : ليست دستورات",
		"/help> : راهنمای جامع",
	},
	patterns = {
		"^[Hh](elp)$",
		"^[Hh](elps)$",
		"^/help$",
		"^[Hh]elp (.+)$",
		"^[Hh]elps (.+)$",
	},
	run = run
} 
end