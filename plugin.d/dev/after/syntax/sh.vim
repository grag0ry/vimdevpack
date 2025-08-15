if exists("b:is_bash")
" coreutils
syn keyword bashStatement arch b2sum base32 base64 basename basenc cat chcon
syn keyword bashStatement chgrp chmod chown chroot cksum comm cp csplit cut
syn keyword bashStatement date dd df dir dircolors dirname du echo env expand
syn keyword bashStatement expr factor false fmt fold head hostid id install
syn keyword bashStatement join link ln logname ls md5sum mkdir mkfifo mknod
syn keyword bashStatement mktemp mv nice nl nohup nproc numfmt od paste
syn keyword bashStatement pathchk pinky pr printenv printf ptx pwd readlink
syn keyword bashStatement realpath rm rmdir runcon seq sha1sum sha224sum
syn keyword bashStatement sha256sum sha384sum sha512sum shred shuf sleep sort
syn keyword bashStatement split stat stdbuf stty sum sync tac tail tee test
syn keyword bashStatement timeout touch tr true truncate tsort tty uname
syn keyword bashStatement unexpand uniq unlink users vdir wc who whoami yes
" util-linux
syn keyword bashStatement dmesg findmnt lsblk lsfd more mount mountpoint
syn keyword bashStatement pipesz su umount wdctl agetty blkdiscard blkid blkpr
syn keyword bashStatement blkzone blockdev cfdisk chcpu ctrlaltdel fdisk
syn keyword bashStatement findfs fsck fsck.cramfs fsck.minix fsfreeze fstrim
syn keyword bashStatement hwclock losetup mkfs mkfs.bfs mkfs.cramfs mkfs.minix
syn keyword bashStatement mkswap pivot_root runuser sfdisk sulogin swaplabel
syn keyword bashStatement swapoff swapon switch_root wipefs zramctl bits cal
syn keyword bashStatement chmem choom chrt col colcrt colrm column coresched
syn keyword bashStatement eject enosys exch fadvise fallocate fincore flock
syn keyword bashStatement getopt hardlink hd hexdump i386 ionice ipcmk ipcrm
syn keyword bashStatement ipcs irqtop isosize last lastb line linux32 linux64
syn keyword bashStatement logger look lsclocks lscpu lsipc lsirq lslocks
syn keyword bashStatement lslogins lsmem lsns mcookie namei nsenter pg prlimit
syn keyword bashStatement rename renice rev script scriptlive scriptreplay
syn keyword bashStatement setarch setpgid setsid setterm taskset uclampset ul
syn keyword bashStatement uname26 unshare utmpdump uuidgen uuidparse waitpid
syn keyword bashStatement whereis x86_64 addpart delpart ldattach partx
syn keyword bashStatement readprofile resizepart rfkill rtcwake
endif

if exists("b:is_kornshell") || exists("b:is_posix")
" coreutils
syn keyword kshStatement arch b2sum base32 base64 basename basenc cat chcon
syn keyword kshStatement chgrp chmod chown chroot cksum comm cp csplit cut
syn keyword kshStatement date dd df dir dircolors dirname du echo env expand
syn keyword kshStatement expr factor false fmt fold head hostid id install
syn keyword kshStatement join link ln logname ls md5sum mkdir mkfifo mknod
syn keyword kshStatement mktemp mv nice nl nohup nproc numfmt od paste
syn keyword kshStatement pathchk pinky pr printenv printf ptx pwd readlink
syn keyword kshStatement realpath rm rmdir runcon seq sha1sum sha224sum
syn keyword kshStatement sha256sum sha384sum sha512sum shred shuf sleep sort
syn keyword kshStatement split stat stdbuf stty sum sync tac tail tee test
syn keyword kshStatement timeout touch tr true truncate tsort tty uname
syn keyword kshStatement unexpand uniq unlink users vdir wc who whoami yes
" util-linux
syn keyword kshStatement dmesg findmnt lsblk lsfd more mount mountpoint
syn keyword kshStatement pipesz su umount wdctl agetty blkdiscard blkid blkpr
syn keyword kshStatement blkzone blockdev cfdisk chcpu ctrlaltdel fdisk
syn keyword kshStatement findfs fsck fsck.cramfs fsck.minix fsfreeze fstrim
syn keyword kshStatement hwclock losetup mkfs mkfs.bfs mkfs.cramfs mkfs.minix
syn keyword kshStatement mkswap pivot_root runuser sfdisk sulogin swaplabel
syn keyword kshStatement swapoff swapon switch_root wipefs zramctl bits cal
syn keyword kshStatement chmem choom chrt col colcrt colrm column coresched
syn keyword kshStatement eject enosys exch fadvise fallocate fincore flock
syn keyword kshStatement getopt hardlink hd hexdump i386 ionice ipcmk ipcrm
syn keyword kshStatement ipcs irqtop isosize last lastb line linux32 linux64
syn keyword kshStatement logger look lsclocks lscpu lsipc lsirq lslocks
syn keyword kshStatement lslogins lsmem lsns mcookie namei nsenter pg prlimit
syn keyword kshStatement rename renice rev script scriptlive scriptreplay
syn keyword kshStatement setarch setpgid setsid setterm taskset uclampset ul
syn keyword kshStatement uname26 unshare utmpdump uuidgen uuidparse waitpid
syn keyword kshStatement whereis x86_64 addpart delpart ldattach partx
syn keyword kshStatement readprofile resizepart rfkill rtcwake
endif

