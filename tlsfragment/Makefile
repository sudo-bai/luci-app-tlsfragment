include $(TOPDIR)/rules.mk

PKG_NAME:=tlsfragment
PKG_VERSION:=3.1.1
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=OpenWrt Community
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/tlsfragment
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=TLS Fragment Proxy
  URL:=https://github.com/maoist2009/TlsFragment
  DEPENDS:=+python3-light +python3-logging +python3-codecs +python3-ctypes +python3-email +python3-urllib +python3-uuid
  PKGARCH:=all
endef

define Package/tlsfragment/description
  TLS fragmentation proxy to bypass network censorship.
  Supports HTTP/SOCKS5 proxy with domain-based routing.
  
  This package provides a lightweight Python-based proxy that can fragment
  TLS handshakes to bypass certain types of network filtering.
endef

define Package/tlsfragment/conffiles
/etc/config/tlsfragment
/etc/tlsfragment/config.json
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	# No compilation needed for Python package
endef

define Package/tlsfragment/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/python3.11/site-packages/tlsfragment
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/tlsfragment
	$(INSTALL_DIR) $(1)/etc/init.d
	
	# Install Python package files
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/__init__.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/config.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/dns_resolver.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/proxy.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/server.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	$(INSTALL_DATA) ./files/usr/lib/python3.11/site-packages/tlsfragment/utils.py $(1)/usr/lib/python3.11/site-packages/tlsfragment/
	
	# Install main script
	$(INSTALL_BIN) ./files/usr/bin/tlsfragment $(1)/usr/bin/
	
	# Install configuration files
	$(INSTALL_CONF) ./files/etc/config/tlsfragment $(1)/etc/config/
	$(INSTALL_CONF) ./files/etc/tlsfragment/config.json $(1)/etc/tlsfragment/
	
	# Install init script
	$(INSTALL_BIN) ./files/etc/init.d/tlsfragment $(1)/etc/init.d/
endef

define Package/tlsfragment/postinst
#!/bin/sh
# Check if we are on a real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Enabling tlsfragment service..."
	/etc/init.d/tlsfragment enable
	
	# Create necessary directories
	mkdir -p /tmp/tlsfragment
	
	echo "TLS Fragment installed successfully!"
	echo "Configure it via LuCI or edit /etc/config/tlsfragment"
fi
exit 0
endef

define Package/tlsfragment/prerm
#!/bin/sh
# Check if we are on a real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Stopping tlsfragment service..."
	/etc/init.d/tlsfragment stop
	/etc/init.d/tlsfragment disable
fi
exit 0
endef

$(eval $(call BuildPackage,tlsfragment))
