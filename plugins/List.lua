local function run(msg)
	sban = redis:smembers('superbanned:')
	i=0
	message = ""
	for k,v in pairs(sban) do
		message = message..i..'- @'..v..' ('..k..')\n'
		i=i+1
	end
	return superbanned
end

return {
	description = "User Infomation",
	patterns = {
		"^[Ss]banlist$",
		"^[Bb]anlist$",
	},
	run = run,
}