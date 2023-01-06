!/usr/bin/env bash

watch=(/root/Cani/ /root/somewhere1/)
recursive="--recursive"
exclude=""
src=(/root/Cani/ /root/somewhere1/)
dst=(/root/Cani2/ /root/somewhere2/)

sym_create() {
ln -s "${1}" "${2}" 
 return
}
sym_remove() {
unlink "${1}"
return
}

inotifywait --exclude "${exclude:-\$^}" "${recursive}" --monitor "${watch[@]}" |
    while read -r directory event file; do
        case "${event}" in
	    CREATE*)
		if [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[0]}" ]]; then
			   echo "Linking ""${watch[0]}${file}"" to" "${dst[0]}${file}"
			    sym_create "${src[0]}${file}" "${dst[0]}${file}"
		else
			 echo "Linking ""${watch[1]}${file}"" to" "${dst[1]}${file}"
			sym_create "${src[1]}${file}" "${dst[1]}${file}"
		fi
	    ;;
    MOVED_FROM*)
	     if [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[0]}" ]]; then
		     if [[ -L ${dst[0]}${file} ]]; then
			     rm -rf "${dst[0]}${file}"
		     fi
	     elif [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[1]}" ]]; then
                     if [[ -L ${dst[1]}${file} ]]; then
                             rm -rf "${dst[1]}${file}"  
                     fi
		else 
			echo "No changes" > stderr
		     
	     fi
		;;
	    MOVED_TO*)  
		    if [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[0]}" ]]; then
				echo "Linking ""${watch[0]}${file}"" to" "${dst[0]}${file}"
				sym_create "${src[0]}${file}" "${dst[0]}${file}"
		   elif [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[1]}" ]]; then
                                echo "Linking ""${watch[1]}${file}"" to" "${dst[1]}${file}"
                                sym_create "${src[1]}${file}" "${dst[1]}${file}"
		   else
			  echo "No changes" > stderr
		   fi
		;;

	    DELETE*)
		if [[ $? -eq 0 ]] && [[ "${directory}" == "${watch[0]}" ]]; then
                           echo "Removing ${dst[0]}${file}"      
                            sym_remove "${dst[0]}${file}"
                else
                         echo "Removing ${dst[1]}${file}"
                        sym_remove "${dst[1]}${file}"
                fi
            ;;

        esac
    done
