!/usr/bin/env bash

watch="."
#recursive="--recursive"
exclude=""
src="/root/Cani/"
dst="/root/Cani2/"
sym_changes() {
my_link="$1"
echo "mylink: ${my_link}"
if [[ -L ${my_link} ]] ; then
      return 0
   else
      return 1
fi
}

sym_create() {
 ln -s "${1}" "${dst}"  
 return
}
sym_remove() {
unlink "${1}"
return
}

inotifywait --exclude "${exclude:-\$^}" ${recursive} --monitor "${watch}" |
    while read -r directory event file; do
        case "${event}" in
	    CREATE*)
		if [[ $? -eq 0 ]] && [[ -d "${file}" ]] ; then
			sym_create ${src}${file}
		else
			echo "${file} isn't a directory" > /dev/stderr
		fi
		echo "${file} created" > /dev/stderr
	    ;;
	    DELETE*)
		if [[ $? -eq 0 ]] || [[ -d "${file}" ]] ; then
                        sym_remove ${dst}${file}
                else
                        echo "${file} isn't a directory" > /dev/stderr
                fi
		echo "${file} was deleted" > /dev/stderr
	    ;;
        esac
    done
