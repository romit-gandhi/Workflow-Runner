# script.sh
if [ -z "$1" ]; then
  echo "Error: No argument provided"
  exit 1
fi
echo "Argument received (length: ${#1})"
echo "Argument: $1"

# Get the argument (secret)
SECRET="$1"

# Get the length of the secret
LENGTH=${#SECRET}
echo "Argument length: $LENGTH"

echo "All characters with positions:"
for ((i=0; i<LENGTH; i++)); do
  CHAR="${SECRET:$i:1}"
  echo "Character at position $((i+1)): $CHAR"
done
