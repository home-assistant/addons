#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Mounting external HD and modify the smb.conf
# ==============================================================================
readonly CONF="/usr/share/tempio/smb.gtpl"
declare moredisks
declare autodisks
declare tomountdisks
declare interface
declare ipaddress
declare fstypes
declare dev

function disk2label() { # $1 disk  return (label disk or id)
     local disk=$1
     if [[ $disk == id:* ]]; then
          disk=${disk:3}
          if [ -L /dev/disk/by-id/$disk ]; then
               label=$(lsblk -no label /dev/disk/by-id/$disk)
               if [[ ! -z "$label" && -L "/dev/disk/by-label/$label" ]]; then
                    bashio::log.info "Disk with id ${disk} is labeled $label so $label is used."
                    disk="$label"
               else
                    disk=$1
               fi
          else
               bashio::log.warning "Disk with id ${disk} not found."
               return 1
          fi
     else
          blkid | grep "$disk" >>/dev/null || {
               bashio::log.warning "Disk with label ${disk} not found."
               return 1
          }
     fi
     echo $disk
     return 0
}

# mount a disk from parameters
function mount_disk() { # $1 disk $2 path 
     disk=$1
     path=$2
     
     if [[ $disk == id:* ]]; then
          bashio::log.debug "Disk ${disk:3} is an ID"
          dev=/dev/disk/by-id/${disk:3}
          if [ -L $dev ]; then
               disk=${disk:3}
          else
               unset dev
          fi
     else
          dev=$(blkid |grep "$disk")
     fi

     if [ -z $dev ]; then
          bashio::log.info "Disk ${disk} not found! <SKIP>"
          return 0
     fi

     mdisk=$(printf %b "$disk")

     mkdir -p "$path/$mdisk"
     chmod a+rwx "$path/$mdisk"

     # check with findmnt if the disk is already mounted
     if findmnt -n -o TARGET "$path/$mdisk" >/dev/null 2>&1; then
          bashio::log.info "Disk ${mdisk} is already mounted"
          echo $path/$mdisk >>/tmp/local_mount
          return 0
     else
          # Check FS type and set relative options
          fstype=$(lsblk $dev -no fstype)
          options="nosuid,relatime,noexec"
          type="auto"
          case "$fstype" in
          exfat | vfat | msdos)
               bashio::log.warning "Your ${mdisk} is ${fstype}. Permissions and ACL don't works and this is an EXPERIMENTAL support"
               options="${options},umask=000"
               ;;
          ntfs)
               bashio::log.warning "Your ${mdisk} is ${fstype}. This is an EXPERIMENTAL support"
               options="${options},umask=000"
               type="ntfs3"
               ;;
          *)
               bashio::log.info "Mounting ${mdisk} of type ${fstype}"
               ;;
          esac
          mount -t $type "$dev" "$path/$mdisk" -o $options &&
               echo $path/$mdisk >>/tmp/local_mount && bashio::log.info "Mount ${mdisk}[${fstype}] Success!"
     fi
}

# Mount external drive
bashio::log.info "Protection Mode is $(bashio::addon.protected)"
if $(bashio::addon.protected) && (bashio::config.has_value 'moredisks' || bashio::config.true 'automount'); then
     bashio::log.warning "MoreDisk and Automount ignored because ADDON in Protected Mode!"
     bashio::config.suggest "protected" "moredisk only work when Protection mode is disabled"
elif bashio::config.has_value 'moredisks' || bashio::config.true 'automount'; then
     bashio::log.info "MoreDisk or Automount option found!"

     # Check supported FS
     for mfs in ntfs3 exfat btrfs xfs; do
          modprobe $mfs || bashio::log.warning "$mfs module not available!"
     done
     fstypes=$(IFS=$'\n' echo $(cat /proc/filesystems | grep -v nodev))
     bashio::log.blue "---------------------------------------------------"
     bashio::log.green "Supported fs: ${fstypes}"
     if cat /proc/filesystems | grep -q fuseblk; then bashio::log.green "Supported fusefs: $(find /sbin -name "mount*fuse" | cut -c 13- | tr "\n" " " | sed s/fuse//g)"; fi
     bashio::log.blue "---------------------------------------------------"
     path=/media

     OIFS=$IFS
     IFS=$'\n'

     ## List available Disk with Labels and Id
     if bashio::config.true 'automount'; then
          bashio::log.blue "---------------------------------------------------"
          #autodisks=($(lsblk -E label -n -o label | sed -r '/^\s*$/d' | grep -v hassos | grep pp))
          readarray -t autodisks < <(lsblk -E label -n -o label -i | sed -r '/^\s*$/d' | grep -v hassos)
          if [ ${#autodisks[@]} -eq 0 ]; then
               bashio::log.info "No Disk with labels."
          else
               bashio::log.info "Available Disk Labels:"
               for disk in ${autodisks[@]}; do
                    bashio::log.info "\t${disk}[$(lsblk $(blkid -L "$disk") -no fstype)]"
               done
          fi
          bashio::log.blue "---------------------------------------------------"
     fi

     moredisks=($(bashio::config 'moredisks'))
     if [ ${#moredisks[@]} -eq 0 ]; then
          bashio::log.info "No MoreDisks to mount"
     else
          bashio::log.info "MoreDisks to mount:\n" $(printf "\t%s\n" "${moredisks[@]}")
          i=0
          mmoredisks=()
          for index in "${!moredisks[@]}"; do
               tmpd=$(disk2label "${moredisks[$index]}") &&
                    mmoredisks[$i]=$tmpd &&
                    ((i = i + 1))
          done
          moredisks=("${mmoredisks[@]}")
     fi

     if bashio::config.true 'automount' && [ ${#autodisks[@]} -gt 0 ]; then
          bashio::log.info "Automount is Enabled!"
          tomountdisks=("${autodisks[@]}" "${moredisks[@]}")
          tomountdisks=($(sort -u <<<"${tomountdisks[*]}"))
     else
          tomountdisks=("${moredisks[@]}")
     fi

     if [ ${#tomountdisks[@]} -gt 0 ]; then
          bashio::log.magenta "---------------------------------------------------"
          bashio::log.info "Mounting disks:\n" $(printf "\t%s\n" "${tomountdisks[@]}")
          bashio::log.magenta "---------------------------------------------------"
          for disk in ${tomountdisks[@]}; do
               mount_disk "$disk" "$path" || bashio::log.warning "Fail to mount ${disk}!"
          done
     fi
     IFS=$OIFS

     echo "$path" >/tmp/mountpath
fi
