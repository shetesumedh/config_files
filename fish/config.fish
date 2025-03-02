if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
	set_color blue --bold
	echo "Welcome to Arch Linux"
	#set_color normal
end

bind \t complete-and-search

bind \t accept-autosuggestion

set open nautilus

set -gx code code-insiders
