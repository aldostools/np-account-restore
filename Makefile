PS4_HOST ?= ps4
PS4_PORT ?= 9021

all: build-ps4 build-ps5

build-ps4:
	$(MAKE) PLATFORM=ps4 restore-elf

build-ps5:
	$(MAKE) PLATFORM=ps5 restore-elf

clean:
	rm -f bin/np-restore-account-ps4.elf bin/np-restore-account-ps5.elf

ifdef PLATFORM

ifeq ($(PLATFORM),ps5)
    ifdef PS5_PAYLOAD_SDK
        include $(PS5_PAYLOAD_SDK)/toolchain/prospero.mk
    else
        $(error PS5_PAYLOAD_SDK is undefined)
    endif
    PLATFORM_CFLAGS := -DPS5
else
    ifdef PS4_PAYLOAD_SDK
        include $(PS4_PAYLOAD_SDK)/toolchain/orbis.mk
    else
        $(error PS4_PAYLOAD_SDK is undefined)
    endif
    PLATFORM_CFLAGS :=
endif

CFLAGS := -Wall $(PLATFORM_CFLAGS)
LDFLAGS := -lSceUserService -lSceRegMgr -lkernel

restore-elf: bin/np-restore-account-$(PLATFORM).elf

bin/np-restore-account-$(PLATFORM).elf: np-restore-account.c
	$(CC) $(CFLAGS) -o $@ np-restore-account.c $(LDFLAGS)

endif

test-ps4: bin/np-restore-account-ps4.elf
	nc $(PS4_HOST) $(PS4_PORT) < $<

test-ps5: bin/np-restore-account-ps5.elf
	nc $(PS4_HOST) $(PS4_PORT) < $<

.PHONY: all build-ps4 build-ps5 clean restore-elf test-ps4 test-ps5
