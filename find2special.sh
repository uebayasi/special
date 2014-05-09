#! /bin/sh

main()
{
	init
	findall
	dumpall
	fini
}

init()
{
	all=$( /usr/bin/mktemp )
	txt=$( /usr/bin/mktemp )
	bin=$( /usr/bin/mktemp )
}

fini()
{
	/bin/rm -f ${all} ${txt} ${bin}
}

findall()
{
	/usr/bin/find ${paths} -print >${all}

	# Rely on grep(1)'s -l/-L to identify binary files.
	/usr/bin/xargs /usr/bin/grep -lI . <${all} >${txt}
	/usr/bin/xargs /usr/bin/grep -LI . <${all} >${bin}
}

dumpall()
{
	/bin/echo '/set uname=root gname=wheel'
	{
		dumptxt
		dumpbin
	} |
	/usr/bin/sort -u
}

dumptxt()
{
	path2special ${txt} |

	# Tag confidential files as nodiff to hide the contents.
	/usr/bin/sed -e '/ mode=0600/s/$/ tags=nodiff/'
}

dumpbin()
{
	path2special ${bin} |

	# Tag confidential files as nodiff to hide the contents.
	/usr/bin/sed -e '/ mode=0600/s/$/ tags=nodiff/' |

	# Exclude binary files from backup.
	/usr/bin/sed -e '/ type=file/s/$/ tags=exclude/'
}

path2special()
{
	/usr/sbin/mtree -c -O ${1} |

	# Convert to /etc/mtree/special* format
	/usr/sbin/mtree -C -k type,mode,uname,gname |
	/usr/bin/sed -e 's/ uname=root//; s/ gname=wheel//'
}

set -e
paths="$@"
main
exit 0
