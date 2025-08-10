################################################################################
#
# myhello
#
################################################################################

MYHELLO_VERSION = 1.0
MYHELLO_SITE = $(BR2_EXTERNAL_BRC1ST_PATH)/package/myhello/src
MYHELLO_SITE_METHOD = local

define MYHELLO_BUILD_CMDS
    $(TARGET_CC) $(TARGET_CFLAGS) -Os \
        -o $(@D)/hello $(@D)/hello.c
endef

define MYHELLO_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin/hello
endef

$(eval $(generic-package))