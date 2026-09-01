# Makefile for use with Android's kernel/build system

KBUILD_OPTIONS += CAMERA_KERNEL_ROOT=$(KERNEL_SRC)/$(M)
KBUILD_OPTIONS += KERNEL_ROOT=$(KERNEL_SRC)
KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
# arcfox: TARGET_PRODUCT=rtwo selects config/rtwo.mk (MOT_SENSOR_PRE_POWERUP);
# stock camera.ko proves it (6 MotPreAct strings). AF_NOISE_ELIMINATION gates
# the mot_ois/mot_actuator objects; stock exports them.
KBUILD_OPTIONS += TARGET_PRODUCT=rtwo
KBUILD_OPTIONS += CONFIG_AF_NOISE_ELIMINATION=y
# arcfox: synx v2 (pineapple). QC passes this from camera-kernel/Android.mk
# (dependency.mk -> CAM_SYNX_EXTRA_CONFIGS), which LineageOS kernel.mk never
# reads. Without it Kbuild drops drivers/cam_sync/cam_sync_synx.o and
# -DCONFIG_TARGET_SYNX_ENABLE=1, so cam_generic_fence_parser() rejects
# CAM_GENERIC_FENCE_TYPE_SYNX_OBJ (0x3) with -EINVAL and CamX SIGABRTs in
# CSLCreateAndBindSynxFenceHW(). Stock camera.ko exports the cam_synx_obj_*
# layer and imports synx_create/synx_initialize/... from synx-driver.ko.
KBUILD_OPTIONS += TARGET_SYNX_ENABLE=y
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
