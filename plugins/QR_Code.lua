do
local function send_titleqr(cb_extra, success, result)
	if success then
		send_msg(cb_extra[1], cb_extra[2], ok_cb, false)
	end
end

local function run(msg, matches)
	local eq = URL.escape(matches[1])
	local url = "http://www.barcodes4.me/barcode/qr/umbrellaqr.png&size=10&ecclevel=3?value="..eq
	local receiver = get_receiver(msg)
	send_photo_from_url(receiver, url, send_titleqr, {receiver})
end

return {
	description = "QR-Code Maker",
	usagehtm = '<tr><td align="center">qrcode متن</td><td align="right">با این دستور قادر به ساخت کیو آر کد هستید. برای ساخت کیو آر کد از لینک، به روش زیر عمل کنید<br>http://آدرس سایت یا فایل مورد نظر<br>مثال: http://www.shayan-soft.ir</td></tr>',
	usage = {
		"qrcode (txt) : ساخت بارکد"
	},
	patterns = {
		"^[Qq]rcode (.+)$"
	},
	run = run
}
end

