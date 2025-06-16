# script.sh
if [ -z "$1" ]; then
  echo "Error: No argument provided"
  exit 1
fi
echo "Argument received (length: ${#1})"
echo "Argument: $1"

# Option 1: Print first 10 characters (or all if less than 10)
if [ $LENGTH -ge 10 ]; then
  echo "First 10 characters (substring): ${SECRET:0:10}"
else
  echo "First $LENGTH characters (substring): ${SECRET:0:LENGTH}"
fi
