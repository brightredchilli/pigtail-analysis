die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='rh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_testratio=


print_help()
{
	printf '%s\n' "Generate train.txt, test.txt based on files in directory_name"
	printf 'Usage: %s [-r|--testratio <arg>] [-h|--help] <directory_name>\n' "$0"
	printf '\t%s\n' "<directory_name>: directory name to look for annotation files"
	printf '\t%s\n' "-r, --testratio: Ratio of test to train in the entire dataset. If excluded, test.txt is not generated. For example, a value of 0.2 will make exclude every 5th image from train.txt and put it into test.txt, 4-1 train-to-test ratio (no default) [NOT IMPLEMENTED]"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-r|--testratio)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_testratio="$2"
				shift
				;;
			--testratio=*)
				_arg_testratio="${_key##--testratio=}"
				;;
			-r*)
				_arg_testratio="${_key##-r}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'directory_name'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_directory_name "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"



# Couldn't do read -r because it interacted very weirdly with ffmpeg, this is a workaround
lines=(`ls $_arg_directory_name/*_* | awk -F/ '{ print "data/obj/"$(NF) }' | sed 's/txt$/jpg/'`)

# clear files
> "train.txt"
> "test.txt"

x=0
for line in "${lines[@]}"; do
  x=$(echo "$x + $_arg_testratio" | bc)
  gtone=$(echo "$x > 1" | bc)
  if [[ $gtone == "1" ]]; then
    x=$(echo "$x % 1" | bc)
    echo $line >> "test.txt"
  else
    echo $line >> "train.txt"
  fi
done
