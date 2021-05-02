#!/usr/bin/env bash
# Modified version of passmenu to copy/type username
# instead of password after selecting entry using dmenu.

shopt -s nullglob globstar

typeit=0
if [[ $1 == "--type" ]]; then
	        typeit=1
		        shift
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

username=$(printf '%s\n' "${password_files[@]}" | dmenu -l 5 -i "$@" -p "Username?")

[[ -n $username ]] || exit

if [[ $typeit -eq 0 ]]; then
	        pass show -c2 "$username" 2>/dev/null
	else
				# Check for line beginning with "user:", "username:", "Username:", etc.
				# Then, grab everything after the user portion, and type
				# it out to the screen
		        pass show "$username" | grep -i "^user.*: " | cut -d ' ' -f2- |
								{ IFS= read -r pass; printf %s "$pass"; } |
				                xdotool type --clearmodifiers --file -
fi
