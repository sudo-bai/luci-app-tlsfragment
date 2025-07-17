-- Copyright 2024 OpenWrt Community
-- Licensed under GPL-3.0

local m, s, o
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("tlsfragment", translate("TLS Fragment Proxy"), 
    translate("TLS fragmentation proxy to bypass network censorship and filtering"))

-- Service Status Section
s = m:section(TypedSection, "tlsfragment", translate("Service Status"))
s.anonymous = true
s.addremove = false

-- Status display
local status = s:option(DummyValue, "_status", translate("Current Status"))
status.template = "tlsfragment/status"

-- General Settings Section
s = m:section(TypedSection, "tlsfragment", translate("General Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable Service"))
o.default = "0"
o.rmempty = false

o = s:option(Value, "port", translate("Listen Port"))
o.datatype = "port"
o.default = "8080"
o.placeholder = "8080"
o.description = translate("Port for the proxy server to listen on")

o = s:option(ListValue, "loglevel", translate("Log Level"))
o:value("DEBUG", translate("Debug"))
o:value("INFO", translate("Info"))
o:value("WARNING", translate("Warning"))
o:value("ERROR", translate("Error"))
o.default = "INFO"
o.description = translate("Logging verbosity level")

o = s:option(ListValue, "mode", translate("Proxy Mode"))
o:value("TLSfrag", translate("TLS Fragmentation"))
o:value("FAKEdesync", translate("Fake Desync"))
o:value("DIRECT", translate("Direct Proxy"))
o.default = "TLSfrag"
o.description = translate("Method used to bypass filtering")

-- TLS Fragment Settings Section
s = m:section(TypedSection, "tlsfragment", translate("TLS Fragmentation Settings"))
s.anonymous = true
s.addremove = false
s:depends("mode", "TLSfrag")

o = s:option(Value, "num_tcp_pieces", translate("TCP Pieces"))
o.datatype = "uinteger"
o.default = "8"
o.placeholder = "8"
o.description = translate("Number of TCP fragments")

o = s:option(Value, "num_tls_pieces", translate("TLS Pieces"))
o.datatype = "uinteger"
o.default = "8"
o.placeholder = "8"
o.description = translate("Number of TLS fragments")

o = s:option(Value, "len_tcp_sni", translate("TCP SNI Length"))
o.datatype = "uinteger"
o.default = "4"
o.placeholder = "4"
o.description = translate("Length of TCP SNI fragments")

o = s:option(Value, "len_tls_sni", translate("TLS SNI Length"))
o.datatype = "uinteger"
o.default = "4"
o.placeholder = "4"
o.description = translate("Length of TLS SNI fragments")

o = s:option(Value, "send_interval", translate("Send Interval"))
o.datatype = "ufloat"
o.default = "0.01"
o.placeholder = "0.01"
o.description = translate("Interval between fragment sends (seconds)")

-- Fake Desync Settings Section
s = m:section(TypedSection, "tlsfragment", translate("Fake Desync Settings"))
s.anonymous = true
s.addremove = false
s:depends("mode", "FAKEdesync")

o = s:option(ListValue, "fake_ttl", translate("Fake TTL"))
o:value("query", translate("Auto Query"))
o:value("8", "8")
o:value("16", "16")
o:value("32", "32")
o:value("64", "64")
o.default = "query"
o.description = translate("TTL value for fake packets")

o = s:option(Value, "fake_sleep", translate("Fake Sleep"))
o.datatype = "ufloat"
o.default = "0.2"
o.placeholder = "0.2"
o.description = translate("Sleep time after sending fake packet (seconds)")

-- DNS Settings Section
s = m:section(TypedSection, "tlsfragment", translate("DNS Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "doh_server", translate("DoH Server"))
o.default = "https://cloudflare-dns.com/dns-query?dns="
o.placeholder = "https://cloudflare-dns.com/dns-query?dns="
o.description = translate("DNS over HTTPS server URL")

o = s:option(Flag, "dns_cache", translate("Enable DNS Cache"))
o.default = "1"
o.description = translate("Cache DNS queries to improve performance")

o = s:option(Value, "dns_cache_ttl", translate("DNS Cache TTL"))
o.datatype = "uinteger"
o.default = "259200"
o.placeholder = "259200"
o.description = translate("DNS cache time-to-live in seconds (default: 3 days)")
o:depends("dns_cache", "1")

o = s:option(Flag, "ttl_cache", translate("Enable TTL Cache"))
o.default = "1"
o.description = translate("Cache TTL detection results")

-- Advanced Settings Section
s = m:section(TypedSection, "tlsfragment", translate("Advanced Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "socket_timeout", translate("Socket Timeout"))
o.datatype = "uinteger"
o.default = "120"
o.placeholder = "120"
o.description = translate("Socket timeout in seconds")

o = s:option(Flag, "safety_check", translate("Safety Check"))
o.default = "0"
o.description = translate("Enable additional safety checks")

o = s:option(Flag, "udp_fake_dns", translate("UDP Fake DNS"))
o.default = "1"
o.description = translate("Use fake DNS responses for UDP queries")

o = s:option(Flag, "by_sni_first", translate("Process by SNI First"))
o.default = "0"
o.description = translate("Process connections by SNI before other methods")

-- Domain Management Section
s = m:section(TypedSection, "domains", translate("Proxy Domains"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.description = translate("Domains that should be processed by the proxy")

o = s:option(Value, "domain", translate("Domain"))
o.rmempty = false
o.placeholder = "example.com"
o.description = translate("Domain name or pattern")

-- Service Control Section
s = m:section(TypedSection, "tlsfragment", translate("Service Control"))
s.anonymous = true
s.addremove = false

local apply = s:option(Button, "_apply", translate("Apply Settings"))
apply.inputstyle = "apply"

local restart = s:option(Button, "_restart", translate("Restart Service"))
restart.inputstyle = "reload"

local stop = s:option(Button, "_stop", translate("Stop Service"))
stop.inputstyle = "remove"

function apply.write()
	sys.call("/etc/init.d/tlsfragment reload")
end

function restart.write()
	sys.call("/etc/init.d/tlsfragment restart")
end

function stop.write()
	sys.call("/etc/init.d/tlsfragment stop")
end

return m
