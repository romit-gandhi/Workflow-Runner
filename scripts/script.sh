# script.sh
if [ -z "$1" ]; then
  echo "Error: No argument provided"
  exit 1
fi
echo "Argument received (length: ${#1})"
echo "Argument: $1"
echo "First character: ${1:0:1}" # Be cautious; avoid revealing sensitive parts
