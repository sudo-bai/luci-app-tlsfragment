include $(TOPDIR)/rules.mk

LUCI_TITLE:=TLS Fragment Proxy
LUCI_DEPENDS:=+tlsfragment +luci-base +luci-compat +luci-mod-admin-full
LUCI_PKGARCH:=all

PKG_VERSION:=1.1.0
PKG_RELEASE:=3

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-tlsfragment/description
TLS fragmentation proxy to bypass network censorship.

This LuCI application provides a web interface for configuring
TLS Fragment proxy settings including:
- Enable/disable the service
- Configure proxy mode (TLS fragmentation, fake desync, direct)
- Set fragmentation parameters
- Manage domain lists
- DNS and caching settings
endef

define Package/luci-app-tlsfragment/conffiles
/etc/config/tlsfragment
endef

define Package/luci-app-tlsfragment/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/tlsfragment
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_DATA) ./luasrc/controller/tlsfragment.lua $(1)/usr/lib/lua/luci/controller/tlsfragment.lua
	$(INSTALL_DATA) ./luasrc/model/cbi/tlsfragment.lua $(1)/usr/lib/lua/luci/model/cbi/tlsfragment.lua
	$(INSTALL_DATA) ./luasrc/view/tlsfragment/status.htm $(1)/usr/lib/lua/luci/view/tlsfragment/status.htm
	$(INSTALL_BIN) ./root/etc/uci-defaults/40_luci-tlsfragment $(1)/etc/uci-defaults/40_luci-tlsfragment
	$(INSTALL_CONF) ./root/etc/config/tlsfragment $(1)/etc/config/tlsfragment
	$(INSTALL_DIR) $(1)/usr/share/luci/acl.d
	$(INSTALL_DATA) ./root/usr/share/luci/acl.d/luci-app-tlsfragment.json $(1)/usr/share/luci/acl.d/luci-app-tlsfragment.json
endef

define Package/luci-app-tlsfragment/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Configuring LuCI for TLS Fragment..."
	if [ -f /etc/uci-defaults/40_luci-tlsfragment ]; then
		( . /etc/uci-defaults/40_luci-tlsfragment ) && rm -f /etc/uci-defaults/40_luci-tlsfragment
	fi
	rm -f /tmp/luci-indexcache
	rm -rf /tmp/luci-modulecache/* 2>/dev/null
	if [ -x /etc/init.d/uhttpd ]; then
		/etc/init.d/uhttpd restart
	fi
	echo "LuCI TLS Fragment application installed successfully!"
fi
exit 0
endef

define Package/luci-app-tlsfragment/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Removing LuCI TLS Fragment application..."
	rm -f /tmp/luci-indexcache
	rm -rf /tmp/luci-modulecache/* 2>/dev/null
	uci -q delete ucitrack.@tlsfragment[-1] 2>/dev/null
	uci -q commit ucitrack 2>/dev/null
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-tlsfragment))
