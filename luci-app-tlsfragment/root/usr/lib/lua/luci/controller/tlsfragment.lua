module("luci.controller.tlsfragment", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/tlsfragment") then
        return
    end

    local page = entry({"admin", "services", "tlsfragment"}, 
                      cbi("tlsfragment"), _("TLS Fragment"), 60)
    page.dependent = true
    
    entry({"admin", "services", "tlsfragment", "status"}, 
          call("action_status")).leaf = true
end

function action_status()
    local sys = require "luci.sys"
    local uci = require "luci.model.uci".cursor()
    local status = {}
    
    -- Check if service is running
    local running = sys.call("pgrep -f tlsfragment > /dev/null 2>&1") == 0
    status.running = running
    
    -- Get configuration
    status.enabled = uci:get("tlsfragment", "main", "enabled") == "1"
    status.port = uci:get("tlsfragment", "main", "port") or "8080"
    status.mode = uci:get("tlsfragment", "main", "mode") or "TLSfrag"
    
    -- Get domain count
    local domains = {}
    uci:foreach("tlsfragment", "domains", function(s)
        if s.domain then
            table.insert(domains, s.domain)
        end
    end)
    status.domain_count = #domains
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(status)
end