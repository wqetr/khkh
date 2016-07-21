local function run(msg, matches)
	local url = "http://tts.baidu.com/text2audio.ogg?lan=en&ie=UTF-8&text="..URL.escape(matches[1])
	local file_path = download_to_file(url, "Umbrella_TTS")
	return send_audio("chat#id"..msg.to.id, file_path, ok_cb, false)
end

return {
	description = "TTS system",
	usagehtm = '<tr><td align="center">tts متن</td><td align="right">با اين دستور ميتوانيد متون انگليسي را به گفتار تبديل کنيد</td></tr>',
	usage = {"tts (text) : متن به گفتار",},
	patterns = {"^[Tt]ts (.*)$",},
	run = run
}