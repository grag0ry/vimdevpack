nnoremap <buffer> \h :SwitchSourceHeader<CR>
nnoremap <buffer> \s :SplitSwitchSourceHeader<CR>
nnoremap <buffer> \v :VSplitSwitchSourceHeader<CR>

syn match cCustomType "\<\w\+_t\>"

" stdint.h
syn keyword cType int8_t int16_t int32_t int64_t
syn keyword cType int_fast8_t  int_fast16_t  int_fast32_t  int_fast64_t
syn keyword cType int_least8_t int_least16_t int_least32_t int_least64_t
syn keyword cType intmax_t intptr_t
syn keyword cType uint8_t uint16_t uint32_t uint64_t
syn keyword cType uint_fast8_t  uint_fast16_t  uint_fast32_t  uint_fast64_t
syn keyword cType uint_least8_t uint_least16_t uint_least32_t uint_least64_t
syn keyword cType uintmax_t uintptr_t

" POSIX constants
syn keyword cPosixConstant DN_ACCESS DN_ATTRIB DN_CREATE DN_DELETE DN_MODIFY
syn keyword cPosixConstant DN_MULTISHOT DN_RENAME F_ADD_SEALS FAPPEND FASYNC
syn keyword cPosixConstant FD_CLOEXEC F_DUPFD F_DUPFD_CLOEXEC F_EXLCK FFSYNC
syn keyword cPosixConstant F_GETFD F_GET_FILE_RW_HINT F_GETFL F_GETLEASE
syn keyword cPosixConstant F_GETLK F_GETLK64 F_GETOWN F_GETOWN_EX F_GETPIPE_SZ
syn keyword cPosixConstant F_GET_RW_HINT F_GET_SEALS F_GETSIG FNDELAY
syn keyword cPosixConstant FNONBLOCK F_NOTIFY F_OFD_GETLK F_OFD_SETLK
syn keyword cPosixConstant F_OFD_SETLKW F_RDLCK F_SEAL_FUTURE_WRITE
syn keyword cPosixConstant F_SEAL_GROW F_SEAL_SEAL F_SEAL_SHRINK F_SEAL_WRITE
syn keyword cPosixConstant F_SETFD F_SET_FILE_RW_HINT F_SETFL F_SETLEASE
syn keyword cPosixConstant F_SETLK F_SETLK64 F_SETLKW F_SETLKW64 F_SETOWN
syn keyword cPosixConstant F_SETOWN_EX F_SETPIPE_SZ F_SET_RW_HINT F_SETSIG
syn keyword cPosixConstant F_SHLCK F_UNLCK F_WRLCK LOCK_EX LOCK_MAND LOCK_NB
syn keyword cPosixConstant LOCK_READ LOCK_RW LOCK_SH LOCK_UN LOCK_WRITE
syn keyword cPosixConstant MAX_HANDLE_SZ O_ACCMODE O_APPEND O_ASYNC O_CLOEXEC
syn keyword cPosixConstant O_CREAT O_DIRECT O_DIRECTORY O_DSYNC O_EXCL O_FSYNC
syn keyword cPosixConstant O_LARGEFILE O_NDELAY O_NOATIME O_NOCTTY O_NOFOLLOW
syn keyword cPosixConstant O_NONBLOCK O_PATH O_RDONLY O_RDWR O_RSYNC O_SYNC
syn keyword cPosixConstant O_TMPFILE O_TRUNC O_WRONLY POSIX_FADV_DONTNEED
syn keyword cPosixConstant POSIX_FADV_NOREUSE POSIX_FADV_NORMAL
syn keyword cPosixConstant POSIX_FADV_RANDOM POSIX_FADV_SEQUENTIAL
syn keyword cPosixConstant POSIX_FADV_WILLNEED RWF_WRITE_LIFE_NOT_SET
syn keyword cPosixConstant RWH_WRITE_LIFE_EXTREME RWH_WRITE_LIFE_LONG
syn keyword cPosixConstant RWH_WRITE_LIFE_MEDIUM RWH_WRITE_LIFE_NONE
syn keyword cPosixConstant RWH_WRITE_LIFE_NOT_SET RWH_WRITE_LIFE_SHORT
syn keyword cPosixConstant SPLICE_F_GIFT SPLICE_F_MORE SPLICE_F_MOVE
syn keyword cPosixConstant SPLICE_F_NONBLOCK SYNC_FILE_RANGE_WAIT_AFTER
syn keyword cPosixConstant SYNC_FILE_RANGE_WAIT_BEFORE SYNC_FILE_RANGE_WRITE
syn keyword cPosixConstant SYNC_FILE_RANGE_WRITE_AND_WAIT

" Win32 types
syn keyword cWinApiType __int3264 __int64 ATOM BOOL BOOLEAN BYTE CCHAR CHAR
syn keyword cWinApiType COLORREF DWORD DWORD32 DWORD64 DWORDLONG DWORD_PTR
syn keyword cWinApiType FLOAT HACCEL HALF_PTR HANDLE HBITMAP HBRUSH
syn keyword cWinApiType HCOLORSPACE HCONV HCONVLIST HCURSOR HDC HDDEDATA HDESK
syn keyword cWinApiType HDROP HDWP HENHMETAFILE HFILE HFONT HGDIOBJ HGLOBAL
syn keyword cWinApiType HHOOK HICON HINSTANCE HKEY HKL HLOCAL HMENU HMETAFILE
syn keyword cWinApiType HMODULE HMONITOR HPALETTE HPEN HRESULT HRGN HRSRC HSZ
syn keyword cWinApiType HWINSTA HWND INT INT16 INT32 INT64 INT8 INT_PTR LANGID
syn keyword cWinApiType LCID LCTYPE LGRPID LONG LONG32 LONG64 LONGLONG
syn keyword cWinApiType LONG_PTR LPARAM LPBOOL LPBYTE LPCOLORREF LPCSTR
syn keyword cWinApiType LPCTSTR LPCVOID LPCWSTR LPDWORD LPHANDLE LPINT LPLONG
syn keyword cWinApiType LPSTR LPTSTR LPVOID LPWORD LPWSTR LRESULT PBOOL
syn keyword cWinApiType PBOOLEAN PBYTE PCHAR PCSTR PCTSTR PCWSTR PDWORD
syn keyword cWinApiType PDWORD32 PDWORD64 PDWORDLONG PDWORD_PTR PFLOAT
syn keyword cWinApiType PHALF_PTR PHANDLE PHKEY PINT PINT16 PINT32 PINT64
syn keyword cWinApiType PINT8 PINT_PTR PLCID PLONG PLONG32 PLONG64 PLONGLONG
syn keyword cWinApiType PLONG_PTR POINTER_32 POINTER_64 POINTER_SIGNED
syn keyword cWinApiType POINTER_UNSIGNED PSHORT PSIZE_T PSSIZE_T PSTR PTBYTE
syn keyword cWinApiType PTCHAR PTSTR PUCHAR PUHALF_PTR PUINT PUINT16 PUINT32
syn keyword cWinApiType PUINT64 PUINT8 PUINT_PTR PULONG PULONG32 PULONG64
syn keyword cWinApiType PULONGLONG PULONG_PTR PUSHORT PVOID PWCHAR PWORD PWSTR
syn keyword cWinApiType QWORD SC_HANDLE SC_LOCK SERVICE_STATUS_HANDLE SHORT
syn keyword cWinApiType SIZE_T SSIZE_T TBYTE TCHAR UCHAR UHALF_PTR UINT UINT16
syn keyword cWinApiType UINT32 UINT64 UINT8 UINT_PTR ULONG ULONG32 ULONG64
syn keyword cWinApiType ULONGLONG ULONG_PTR UNICODE_STRING USHORT USN VOID
syn keyword cWinApiType WCHAR WORD WPARAM
syn keyword cWinApiType PROC FARPROC

" Win32 statements
syn keyword cWinApiStorageClass CONST WINAPI APIENTRY CALLBACK

" POSIX errno
syn keyword cPosixError EPERM ENOENT ESRCH EINTR EIO ENXIO E2BIG ENOEXEC EBADF
syn keyword cPosixError ECHILD EAGAIN ENOMEM EACCES EFAULT ENOTBLK EBUSY EEXIST
syn keyword cPosixError EXDEV ENODEV ENOTDIR EISDIR EINVAL ENFILE EMFILE ENOTTY
syn keyword cPosixError ETXTBSY EFBIG ENOSPC ESPIPE EROFS EMLINK EPIPE EDOM
syn keyword cPosixError ERANGE EDEADLK ENAMETOOLONG ENOLCK ENOSYS ENOTEMPTY
syn keyword cPosixError ELOOP EWOULDBLOCK ENOMSG EIDRM ECHRNG EL2NSYNC EL3HLT
syn keyword cPosixError EL3RST ELNRNG EUNATCH ENOCSI EL2HLT EBADE EBADR EXFULL
syn keyword cPosixError ENOANO EBADRQC EBADSLT EDEADLOCK EBFONT ENOSTR ENODATA
syn keyword cPosixError ETIME ENOSR ENONET ENOPKG EREMOTE ENOLINK EADV ESRMNT
syn keyword cPosixError ECOMM EPROTO EMULTIHOP EDOTDOT EBADMSG EOVERFLOW
syn keyword cPosixError ENOTUNIQ EBADFD EREMCHG ELIBACC ELIBBAD ELIBSCN ELIBMAX
syn keyword cPosixError ELIBEXEC EILSEQ ERESTART ESTRPIPE EUSERS ENOTSOCK
syn keyword cPosixError EDESTADDRREQ EMSGSIZE EPROTOTYPE ENOPROTOOPT
syn keyword cPosixError EPROTONOSUPPORT ESOCKTNOSUPPORT EOPNOTSUPP EPFNOSUPPORT
syn keyword cPosixError EAFNOSUPPORT EADDRINUSE EADDRNOTAVAIL ENETDOWN
syn keyword cPosixError ENETUNREACH ENETRESET ECONNABORTED ECONNRESET ENOBUFS
syn keyword cPosixError EISCONN ENOTCONN ESHUTDOWN ETOOMANYREFS ETIMEDOUT
syn keyword cPosixError ECONNREFUSED EHOSTDOWN EHOSTUNREACH EALREADY EINPROGRESS
syn keyword cPosixError ESTALE EUCLEAN ENOTNAM ENAVAIL EISNAM EREMOTEIO EDQUOT
syn keyword cPosixError ENOMEDIUM EMEDIUMTYPE ECANCELED ENOKEY EKEYEXPIRED
syn keyword cPosixError EKEYREVOKED EKEYREJECTED EOWNERDEAD ENOTRECOVERABLE
syn keyword cPosixError ERFKILL EHWPOISON ENOTSUP

" Win32 errno
syn match cWinApiError "\<ERROR_[A-Z_]\+\>"

" WIN32 constants
syn keyword cWinApiConstant INFINITE WAIT_ABANDONED WAIT_TIMEOUT WAIT_FAILED
syn match cWinApiWaitConstant "\<\(WAIT_OBJECT_\|WAIT_ABANDONED_\)[0-9]\+\>"
hi link cWinApiWaitConstant cWinApiConstant

hi link cPosixError    cConstant
hi link cWinApiError   cConstant
hi link cCustomType    cType
hi link cPosixConstant cConstant
hi link cWinApiType    cType
hi link cWinApiStorageClass cStorageClass
hi link cWinApiConstant cConstant