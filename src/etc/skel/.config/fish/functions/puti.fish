function fish_greeting
  switch (random 1 5)
    case 1
      echo "🐟 The friendly interactive shell says hello!"
    case 2
      echo "🐠 Ready to get to work?"
    case 3
      echo "🐡 Let's make some magic happen."
    case 4
      echo "🐳 What's on the agenda today?"
    case 5
      echo "🦈 Greetings from the terminal!"
  end
end


# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | string trim --right --chars=/)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end


# Fish command history
function history
    builtin history --show-time='%F %T '
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end