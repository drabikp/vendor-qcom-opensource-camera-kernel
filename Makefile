# Makefile for use with Android's kernel/build system

KBUILD_OPTIONS += CAMERA_KERNEL_ROOT=$(KERNEL_SRC)/$(M)
KBUILD_OPTIONS += KERNEL_ROOT=$(KERNEL_SRC)
KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
# arcfox: TARGET_PRODUCT=rtwo selects config/rtwo.mk (MOT_SENSOR_PRE_POWERUP);
# stock camera.ko proves it (6 MotPreAct strings). AF_NOISE_ELIMINATION gates
# the mot_ois/mot_actuator objects; stock exports them.
KBUILD_OPTIONS += TARGET_PRODUCT=rtwo
KBUILD_OPTIONS += CONFIG_AF_NOISE_ELIMINATION=y
KBUILD_EXTRA_SYMBOLS := \
    $(OUT_DIR)/../sm8635-modules/qcom/opensource/mmrm-driver/Module.symvers \
    $(OUT_DIR)/../sm8635-modules/qcom/opensource/securemsm-kernel/Module.symvers \
    $(OUT_DIR)/../sm8635-modules/qcom/opensource/synx-kernel/Module.symvers
KBUILD_OPTIONS += KBUILD_EXTRA_SYMBOLS="$(KBUILD_EXTRA_SYMBOLS)"
KBUILD_OPTIONS += MODNAME=camera

all: modules

CAMERA_COMPILE_TIME = $(shell date)
CAMERA_COMPILE_BY = $(shell whoami | sed 's/\\/\\\\/')
CAMERA_COMPILE_HOST = $(shell uname -n)

cam_generated_h: $(shell find . -iname "*.c") $(shell find . -iname "*.h") $(shell find . -iname "*.mk")
	echo '#define CAMERA_COMPILE_TIME "$(CAMERA_COMPILE_TIME)"' > cam_generated_h
	echo '#define CAMERA_COMPILE_BY "$(CAMERA_COMPILE_BY)"' >> cam_generated_h
	echo '#define CAMERA_COMPILE_HOST "$(CAMERA_COMPILE_HOST)"' >> cam_generated_h

modules: cam_generated_h

modules dtbs:
	$(MAKE) -C $(KERNEL_SRC) M=$(M) modules $(KBUILD_OPTIONS)

modules_install:
	$(MAKE) M=$(M) -C $(KERNEL_SRC) modules_install

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(M) clean
