# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit linux-info

DESCRIPTION="Microcode for Liverpool APU"
HOMEPAGE="https://people.freedesktop.org/~agd5f/radeon_ucode/"
SRC_URI="mirror://gentoo/radeon-ucode-20160628.tar"

LICENSE="radeon-ucode"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="legacy"

RDEPEND=">sys-kernel/linux-firmware-20150812"

S=${WORKDIR}/radeon

src_compile() {
	python "${FILESDIR}"/resize_firmware.py hawaii_pfp.bin 17024 liverpool_pfp.bin
	python "${FILESDIR}"/resize_firmware.py hawaii_me.bin 17024 liverpool_me.bin
}

src_install() {
	insinto /lib/firmware/radeon

	for unit in mec mec2 sdma sdma1 uvd vce; do
		newins kaveri_${unit}.bin liverpool_${unit}.bin
	done

	doins liverpool_pfp.bin
	doins liverpool_me.bin
	newins hawaii_ce.bin liverpool_ce.bin
}

pkg_postinst() {
	ewarn "If you build in AMDGPU into your kernel, it will by default use the"
	ewarn "outdated GPU microcode that ships with the PS4 operating system,"
	ewarn "as provided by ps4-kexec. In order to take advantage of this updated"
	ewarn "microcode, you must build the contents of /lib/firmware/radeon into"
	ewarn "your initramfs, which will then override the legacy versions."
	ewarn
	ewarn "Conversely, this package does not provide liverpool_rlc.bin, for"
	ewarn "which you must use the legacy version provided by ps4-kexec. If"
	ewarn "you are building amdgpu/radeon as a module, you must copy it out"
	ewarn "from the initramfs (as provided by ps4-kexec) into your filesystem"
	ewarn "so it can continue to be used after boot."
	ewarn
	ewarn "You may also want to install sys-kernel/linux-firmware, and also"
	ewarn "copy /lib/firmware/mrvl/sd8797_uapsta.bin to your initramfs if you"
	ewarn "build your WLAN/Bluetooth driver into the kernel."
}
