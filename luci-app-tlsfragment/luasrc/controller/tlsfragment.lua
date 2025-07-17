-- Copyright 2024 OpenWrt Community
-- Licensed under GPL-3.0

module("luci.controller.tlsfragment", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/tlsfragment") then
		return
	end

	-- Main entry point
	local page = entry({"admin", "services", "tlsfragment"}, 
	                  cbi("tlsfragment"), 
	                  _("TLS Fragment"), 60)
	page.dependent = true
	
	-- Status API endpoint
	entry({"admin", "services", "tlsfragment", "status"}, 
	      call("action_status")).leaf = true
	      
	-- Log viewer endpoint
	entry({"admin", "services", "tlsfragment", "log"}, 
	      call("action_log")).leaf = true
end

function action_status()
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	local status = {}
	
	-- Check if service is running
	local running = sys.call("pgrep -f '/usr/bin/tlsfragment' > /dev/null 2>&1") == 0
	status.running = running
	
	-- Get configuration
	status.enabled = uci:get("tlsfragment", "main", "enabled") == "1"
	status.port = uci:get("tlsfragment", "main", "port") or "8080"
	status.mode = uci:get("tlsfragment", "main", "mode") or "TLSfrag"
	status.loglevel = uci:get("tlsfragment", "main", "loglevel") or "INFO"
	
	-- Get domain count
	local domain_count = 0
	uci:foreach("tlsfragment", "domains", function(s)
		if s.domain then
			domain_count = domain_count + 1
		end
	end)
	status.domain_count = domain_count
	
	-- Get system info
	status.uptime = sys.uptime()
	status.loadavg = sys.loadavg()
	
	-- Check port availability
	local port_check = sys.call("netstat -ln | grep ':" .. status.port .. " ' > /dev/null 2>&1") == 0
	status.port_listening = port_check
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

function action_log()
	local sys = require "luci.sys"
	local log_lines = tonumber(luci.http.formvalue("lines")) or 50
	
	-- Get TLS Fragment logs
	local logs = sys.exec("logread | grep -i tlsfragment | tail -" .. log_lines)
	
	luci.http.prepare_content("text/plain; charset=utf-8")
	luci.http.write(logs or "No logs found")
end
