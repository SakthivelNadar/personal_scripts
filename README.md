# Personal Scripts
Collection of scripts to help with Android Kernel stuff.  

1. kernel_rebase_mtk.sh: A script to rebase OEM compressed MTK kernel source to its source with proper commits base.

Usage:` ./tools/kernel_rebase_mtk.sh <kernel zip link/file> <repo name>`

2. kernel-gcc-build.sh: A script for building Kernel with GCC 4.9.

Usage: ` . kernel-mtk/kernel-gcc-build.sh`

3. kernel-clang6-build.sh: A script for building Kernel with Clang 6.

Usage: ` . kernel-mtk/kernel-clang6-build.sh`

4. kernel-clang9-build.sh: A script for building Kernel with Clang 9.

Usage: ` . kernel-mtk/kernel-clang9-build.sh`

5. kernel-evagcc-build.sh: A script for building Kernel with EvaGCC 11.

Usage: ` . kernel-mtk/kernel-evagcc-build.sh`

6. setup_build_env.sh: script for setting up build environment and git credentials.

Usage: ` . tools/setup_build_env.sh`
