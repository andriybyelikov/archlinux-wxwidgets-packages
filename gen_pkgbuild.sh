# !/bin/bash

# Arch Linux base metapackage
# https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/base/trunk/PKGBUILD

depends=(
  'filesystem' 'gcc-libs' 'glibc' 'bash'
  'coreutils' 'file' 'findutils' 'gawk' 'grep' 'procps-ng' 'sed' 'tar'
  'gettext' 'pciutils' 'psmisc' 'shadow' 'util-linux' 'bzip2' 'gzip' 'xz'
  'licenses' 'pacman' 'systemd' 'systemd-sysvcompat'
  'iputils' 'iproute2'
)

# optdepends
optdepends=(
  'webkit2gtk'
)

# https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

filter() {
  packages=()
  for file in $(find-libdeps $1 | sed 's/=.*//' | grep -v libwx); do
    package="$(pacman -Qo /usr/lib/$file | awk '{print $5}')"
    containsElement $package ${packages[@]} # discard repeated packages
    if [ $? -ne 0 ]; then
      containsElement $package ${depends[@]} # discard base packages
      if [ $? -ne 0 ]; then
        containsElement $package ${optdepends[@]} # discard optdepends
        if [ $? -ne 0 ]; then
          packages+=($package)
        fi
      fi
    fi
  done
  echo ${packages[@]} | xargs -n 1 | sort
}

output_dirs=(wxgtk wxgtk-dev)
branch_suffix=("" "-dev")
release=("3.0" "3.1")
subrelease=(".5.1" ".5")
sha256sum=("'440f6e73cf5afb2cbf9af10cec8da6cdd3d3998d527598a53db87099524ac807'"
           "'d7b3666de33aa5c10ea41bb9405c40326e1aeb74ee725bb88f90f1d50270a224'")
desc_branch=("" " (development branch)")
makedepends=("" " curl libsecret")

for i in ${!output_dirs[@]}; do
  wx_runtime_depends="$(filter $(ls ${output_dirs[$i]}/wx-runtime*) | xargs)"
  wxgtk2_runtime_depends="$(filter $(ls ${output_dirs[$i]}/wxgtk2-runtime*) | xargs | sed 's/gtk\(.\) /gtk\1\\n    /g')"
  wxgtk3_runtime_depends="$(filter $(ls ${output_dirs[$i]}/wxgtk3-runtime*) | xargs | sed 's/gtk\(.\) /gtk\1\\n    /g')"
  sed \
    -e 's/@branch_suffix@/'"${branch_suffix[$i]}"'/g' \
    -e 's/@release@/'"${release[$i]}"'/g' \
    -e 's/@subrelease@/'"${subrelease[$i]}"'/g' \
    -e 's/@sha256sum@/'"${sha256sum[$i]}"'/g' \
    -e 's/@desc_branch@/'"${desc_branch[$i]}"'/g' \
    -e 's/@wx_runtime_depends@/'"$wx_runtime_depends"'/g' \
    -e 's/@wxgtk2_runtime_depends@/'"$wxgtk2_runtime_depends"'/g' \
    -e 's/@wxgtk3_runtime_depends@/'"$wxgtk3_runtime_depends"'/g' \
    -e 's/@makedepends@/'"${makedepends[$i]}"'/g' \
    template-wxgtk/PKGBUILD > "${output_dirs[$i]}/PKGBUILD"
done
