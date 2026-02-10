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
	
	-- Service control endpoint
	entry({"admin", "services", "tlsfragment", "control"},
	      post("action_control")).leaf = true
end

function action_status()
	local uci = require "luci.model.uci".cursor()
	local e = {}
	
	-- Check if service is running and get PID
	e.running = luci.sys.call("pgrep -f '/usr/bin/tlsfragment' > /dev/null 2>&1") == 0
	if e.running then
		local pid = luci.sys.exec("pgrep -f '/usr/bin/tlsfragment' | head -1"):match("(%d+)")
		e.pid = pid
	end
	
	-- Get configuration
	e.enabled = uci:get("tlsfragment", "main", "enabled") == "1"
	e.port = uci:get("tlsfragment", "main", "port") or "8080"
	e.mode = uci:get("tlsfragment", "main", "mode") or "TLSfrag"
	
	-- Check port availability
	e.port_listening = luci.sys.call("netstat -ln | grep ':" .. e.port .. " ' > /dev/null 2>&1") == 0
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function action_log()
	local log_lines = tonumber(luci.http.formvalue("lines")) or 50
	local logs = luci.sys.exec("logread | grep -i tlsfragment | tail -" .. log_lines)
	
	luci.http.prepare_content("text/plain; charset=utf-8")
	luci.http.write(logs or "No logs found")
end

function action_control()
	local action = luci.http.formvalue("action")
	local e = { success = false, message = "" }
	
	if action == "start" then
		luci.sys.call("/etc/init.d/tlsfragment start >/dev/null 2>&1")
		e.success = true
		e.message = "Service started"
	elseif action == "stop" then
		luci.sys.call("/etc/init.d/tlsfragment stop >/dev/null 2>&1")
		e.success = true
		e.message = "Service stopped"
	elseif action == "restart" then
		luci.sys.call("/etc/init.d/tlsfragment restart >/dev/null 2>&1")
		e.success = true
		e.message = "Service restarted"
	elseif action == "enable" then
		luci.sys.call("/etc/init.d/tlsfragment enable >/dev/null 2>&1")
		e.success = true
		e.message = "Service enabled"
	elseif action == "disable" then
		luci.sys.call("/etc/init.d/tlsfragment disable >/dev/null 2>&1")
		e.success = true
		e.message = "Service disabled"
	else
		e.message = "Invalid action"
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
