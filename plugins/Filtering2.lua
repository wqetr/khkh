local function pre_process(msg)
	if msg.to.type ~= 'chat' then return end
	if is_momod(msg) then return end
	if tonumber(msg.from.id) == tonumber(our_id) then return end
	if msg.text then
		if redis:smembers("filter:words:groups"..msg.to.id) then
			for k,v in pairs(redis:smembers("filter:words:groups"..msg.to.id)) do
				if msg.text:match(v) then
					if redis:get("filter:warned:user:"..msg.from.id) == true then
						send_large_msg('chat#id'..msg.to.id, "به دليل عدم رعايت قواين گفتاري حذف شديد")
						chat_del_user('chat#id'..msg.to.id, 'user#id'..msg.from.id, ok_cb, true)
						redis:set("filter:warned:user:"..msg.from.id, false)
					else
						send_large_msg('chat#id'..msg.to.id, "کلمه ي کاربردي شما ممنوع است، در صورت تکرار با شما برخورد خواهد شد")
						redis:set("filter:warned:user:"..msg.from.id, true)
					end
				end
			end
		end
	end
end

local function run(msg, matches)
	local filtered_words = redis:smembers("filter:words:groups"..msg.to.id)
	if matches[1] == "ilterlist" then
		local filtered_words = redis:smembers("filter:words:groups"..msg.to.id)
		local text = "ليست کلمات فيلتر شده:\n______________________________"
		text = text.."\n"
		if filtered_words then
			for k,v in pairs(filtered_words) do
				text = text..k.."- "..v.."\n"
			end
		end
		return text
	elseif matches[1] == "ilter" and matches[2] == "+" then
			if not is_momod(msg) then
				return "شما مدير نيستيد"
			else
				if #filtered_words > 25 then
					return "فقط قادر به فيلتر 25 کلمه هستيد"
				end
				redis:sadd("filter:words:groups"..msg.to.id, matches[3])
				return "فيلتر شد"
			end
	elseif matches[1] == "ilter" and matches[2] == "-" then
			if not is_momod(msg) then
				return "شما مدير نيستيد"
			else
				redis:srem("filter:words:groups"..msg.to.id, matches[3])
				return "از فيلتر خارج شد"
			end
	end
end

return {
	description = "Filtering Plugin", 
	usagehtm = '<tr><td align="center">filterlist</td><td align="right">لیست کلمات فیلتر شده</td></tr>'
	..'<tr><td align="center">filter + کلمه</td><td align="right">این دستور کلمه ای را فیلتر میکند به طوری که اگر توسط کاربری استفاده شود، ایشان کیک میگردند. دقت فرمایید بار اول تذکر است</td></tr>'
	..'<tr><td align="center">filter - کلمه</td><td align="right">کلمه ای را از فیلتر خارج میسازد</td></tr>',
	usage = {
	user = {
		"filterlist : لیست فیلتر شده ها",
	},
	moderator = {
		"filter + (word) : فیلتر کردن 1لغت",
		"filter - (word) : حذف از فیلتر",
	},
	},
	patterns = {
		"^[Ff](ilter) (.+) (.*)$",
		"^[Ff](ilterlist)$",
	},
	run = run,
	pre_process = pre_process
}