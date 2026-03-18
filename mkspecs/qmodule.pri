host_build {
    QT_CPU_FEATURES.x86_64 = mmx sse sse2
} else {
    QT_CPU_FEATURES.arm = neon
}
QT.global_private.enabled_features = alloca_h alloca dbus dbus-linked dlopen gui libudev network posix_fallocate reduce_exports relocatable sql system-zlib testlib widgets xml zstd
QT.global_private.disabled_features = sse2 alloca_malloc_h android-style-assets avx2 private_tests gc_binaries intelcet reduce_relocations release_tools stack-protector-strong
PKG_CONFIG_EXECUTABLE = /usr/bin/pkg-config
QMAKE_LIBS_DBUS = -L/home/gamercial/orangepi/sysroot/usr/lib/arm-linux-gnueabihf -ldbus-1
QMAKE_INCDIR_DBUS = /home/gamercial/orangepi/sysroot/usr/include/dbus-1.0 /home/gamercial/orangepi/sysroot/usr/lib/arm-linux-gnueabihf/dbus-1.0/include
QMAKE_LIBS_LIBDL = 
QMAKE_LIBS_LIBUDEV = -L/home/gamercial/orangepi/sysroot/usr/lib/arm-linux-gnueabihf -ludev
QT_COORD_TYPE = double
QMAKE_LIBS_ZLIB = -lz
QMAKE_LIBS_ZSTD = -lzstd
CONFIG += cross_compile compile_examples enable_new_dtags largefile neon precompile_header
QT_BUILD_PARTS += libs
QT_HOST_CFLAGS_DBUS += 
