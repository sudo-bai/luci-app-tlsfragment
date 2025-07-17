local m, s, o

m = Map("tlsfragment", translate("TLS Fragment Proxy"), 
    translate("TLS fragmentation proxy to bypass network censorship"))

-- Main Settings
s = m:section(TypedSection, "tlsfragment", translate("General Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.default = "0"

o = s:option(Value, "port", translate("Listen Port"))
o.datatype = "port"
o.default = "8080"

o = s:option(ListValue, "loglevel", translate("Log Level"))
o:value("DEBUG", "DEBUG")
o:value("INFO", "INFO")
o:value("WARNING", "WARNING")
o:value("ERROR", "ERROR")
o.default = "INFO"

o = s:option(ListValue, "mode", translate("Proxy Mode"))
o:value("TLSfrag", translate("TLS Fragmentation"))
o:value("FAKEdesync", translate("Fake Desync"))
o:value("DIRECT", translate("Direct"))
o.default = "TLSfrag"

-- TLS Fragment Settings
s = m:section(TypedSection, "tlsfragment", translate("TLS Fragment Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "num_tcp_pieces", translate("TCP Pieces"))
o.datatype = "uinteger"
o.default = "8"
o:depends("mode", "TLSfrag")

o = s:option(Value, "num_tls_pieces", translate("TLS Pieces"))
o.datatype = "uinteger"
o.default = "8"
o:depends("mode", "TLSfrag")

o = s:option(Value, "len_tcp_sni", translate("TCP SNI Length"))
o.datatype = "uinteger"
o.default = "4"
o:depends("mode", "TLSfrag")

o = s:option(Value, "len_tls_sni", translate("TLS SNI Length"))
o.datatype = "uinteger"
o.default = "4"
o:depends("mode", "TLSfrag")

o = s:option(Value, "send_interval", translate("Send Interval (seconds)"))
o.datatype = "ufloat"
o.default = "0.01"
o:depends("mode", "TLSfrag")

-- DNS Settings
s = m:section(TypedSection, "tlsfragment", translate("DNS Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "doh_server", translate("DoH Server"))
o.default = "https://cloudflare-dns.com/dns-query?dns="

o = s:option(Flag, "dns_cache", translate("Enable DNS Cache"))
o.default = "1"

o = s:option(Value, "dns_cache_ttl", translate("DNS Cache TTL (seconds)"))
o.datatype = "uinteger"
o.default = "259200"
o:depends("dns_cache", "1")

-- Domain List
s = m:section(TypedSection, "domains", translate("Proxy Domains"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Value, "domain", translate("Domain"))
o.rmempty = false

return m