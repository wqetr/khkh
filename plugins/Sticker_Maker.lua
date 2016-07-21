local function convert_to_sticker(msg, success, result)
	local receiver = get_receiver(msg)
	local file = 'file/sticker.webp'
	os.rename(result, file)
	send_document(receiver, file, ok_cb, false)
end

local function convert_to_photo(msg, success, result)
	local receiver = get_receiver(msg)
	local file = 'file/stconv.png'
	os.rename(result, file)
	send_photo(receiver, file, ok_cb, false)
end

local function get_message_callback_st(extra, success, result)
	if result.media then
		if result.media.type == 'photo' then
			load_photo(result.id, convert_to_sticker, result)
		else
			send_large_msg(orgchatid, 'مورد انتخاب شده عکس نیست')
		end
	else
		send_large_msg(orgchatid, 'فقط قادر به تبدیل عکس به استیکر هستید')
	end
end

local function get_message_callback_pk(extra, success, result)
	if result.media then
		load_photo(result.id, convert_to_photo, result)
	else
		send_large_msg(orgchatid, 'فقط قادر به تبدیل استیکر به عکس هستید')
	end
end

local function run(msg, matches)
	if msg.reply_id then
		if msg.text:lower() == "sticker" then
			orgchatid = 'chat#id'..msg.to.id
			return get_message(msg.reply_id, get_message_callback_st, false)
		elseif msg.text:lower() == "tophoto" then
			orgchatid = 'chat#id'..msg.to.id
			return get_message(msg.reply_id, get_message_callback_pk, false)
		end
	elseif matches[2] then
		local receiver = get_receiver(msg)
		local url = matches[2]
		local ext = matches[3]:lower()
		if ext == 'png' then
			local dlfile = download_to_file(url)
			local file = 'file/sticker.webp'
			os.rename(dlfile, file)
			local cb_extra = {file_path=file}
			send_document(receiver, file, rmtmp_cb, cb_extra)
		elseif ext == 'jpg' then
			local dlfile = download_to_file(url)
			local file = 'file/sticker.webp'
			os.rename(dlfile, file)
			local cb_extra = {file_path=file}
			send_document(receiver, file, rmtmp_cb, cb_extra)
		else
			return 'لینک وارد شده باید شامل عکس با پسوند png یا jpg باشد'
		end
	else
		return 'این دستور را با یک عکس رپلی کنید تا آن عکس به استیکر تبدیل شود یا پس از این دستور، لینک یک عکس را وارد نمایید'
	end
end

return {
	description = "Convert Photo to Sticker", 
	usagehtm = '<tr><td align="center">sticker</td><td align="right">اگر این دستور با عکسی رپلی شود، آن عکس به استیکر تبدیل خواهد شد</td></tr>'
		..'<tr><td align="center">tophoto</td><td align="right">اگر این دستور با استیکری رپلی شود، آن استیکر به عکس تبدیل خواهد شد</td></tr>'
		..'<tr><td align="center">sticker لینک فایل عکس</td><td align="right">دقت کنید لینک وارد شده شامل عکس با فرمت جی پی جی یا پی ان جی باشد، آن عکس به استیکر تبدیل خواهد شد</td></tr>',
	usage = {
		"sticker (reply|link): تبدیل عکس به استیکر",
		"tophoto : تبدیل استیکر به عکس",
		},
	patterns = {
		"^[Tt]ophoto$",
		"^[Ss]ticker$",
		"^[Ss](ticker) (http?://[%w-_%.%?%.:/%+=&]+%.(.*))$",
		"^[Ss](ticker) (https?://[%w-_%.%?%.:/%+=&]+%.(.*))$",
	}, 
	run = run
}