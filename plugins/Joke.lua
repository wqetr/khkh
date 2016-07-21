local function run(msg)
	local file = io.open("./file/joke.db", "r")
	local text = file:read("*all")
	local joke = text:split(",")
	return joke[math.random(#joke)]
end

return {
	description = "",
	usagehtm = '<tr><td align="center">joke</td><td align="right">پانصد جوک متنوع به صورت رندوم</td></tr>',
	usage = "joke : ارسال جوک",
	patterns = {"^[Jj]oke$"},
	run = run
}
