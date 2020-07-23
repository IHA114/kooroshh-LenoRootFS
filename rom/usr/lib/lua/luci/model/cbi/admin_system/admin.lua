-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"

m = Map("system", translate("Router Password"),
	translate("Changes the administrator password for accessing the device"))

s = m:section(TypedSection, "_dummy", "")
s.addremove = false
s.anonymous = true

pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

pw2 = s:option(Value, "pw2", translate("Confirmation"))
pw2.password = true

function s.cfgsections()
	return { "_pass" }
end

function m.parse(map)
	local v1 = pw1:formvalue("_pass")
	local v2 = pw2:formvalue("_pass")

	if v1 and v2 and #v1 > 0 and #v2 > 0 then
		if v1 == v2 then
			if luci.sys.user.setpasswd(luci.dispatcher.context.authuser, v1) == 0 then
				m.message = translate("Password successfully changed!")
			else
				m.message = translate("Unknown Error, password not changed!")
			end
		else
			m.message = translate("Given password confirmation did not match, password not changed!")
		end
	end

	Map.parse(map)
end


if fs.access("/etc/config/dropbear") then

m2 = Map("dropbear", translate("SSH Access"),
	translate("Dropbear offers <abbr title=\"Secure Shell\">SSH</abbr> network shell access and an integrated <abbr title=\"Secure Copy\">SCP</abbr> server"))


s2 = m2:section(TypedSection, "_dummy", translate("SSH-Keys"),
	translate("Here you can paste public SSH-Keys (one per line) for SSH public-key authentication."))
s2.addremove = false
s2.anonymous = true
s2.template  = "cbi/tblsection"

function s2.cfgsections()
	return { "_keys" }
end

keys = s2:option(TextValue, "_data", "")
keys.wrap    = "off"
keys.rows    = 3

function keys.cfgvalue()
	return fs.readfile("/etc/dropbear/authorized_keys") or ""
end

function keys.write(self, section, value)
	return fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"))
end

function keys.remove(self, section, value)
	return fs.writefile("/etc/dropbear/authorized_keys", "")
end

end

return m, m2