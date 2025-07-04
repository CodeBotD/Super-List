#!/bin/bash

SUPERLIST_DIR="$HOME/.superlist"
CURRENT_FILE="$SUPERLIST_DIR/.current"

mkdir -p "$SUPERLIST_DIR"

print_mascot() {
cat << "EOF"
  .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.
 / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \
`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-

        Super List! 📋   with Lil’ Fishy 🐟
               \_/ o\
               /\__/
EOF
}

case "$1" in
  new)
    FILENAME="$SUPERLIST_DIR/$2.txt"
    touch "$FILENAME"
    echo "$FILENAME" > "$CURRENT_FILE"
    echo "Added \"$2\""
    ;;
  open)
    FILENAME="$SUPERLIST_DIR/$2.txt"
    if [ -f "$FILENAME" ]; then
      echo "$FILENAME" > "$CURRENT_FILE"
      echo "Opened \"$2\""
    else
      echo "❌ List \"$2\" doesn't exist."
    fi
    ;;
  add)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo "❌ No list opened. Use 'sl open <name>'"
      exit 1
    fi
    echo "[ ] ${2} | ${3}" >> "$(cat $CURRENT_FILE)"
    echo "✅ Added: $2 (Due $3)"
    ;;
  done)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo "❌ No list opened."
      exit 1
    fi
    sed -i '' "${2}s/\[ \]/[x]/" "$(cat $CURRENT_FILE)"
    echo "✔️ Marked task #$2 as done!"
    ;;
  view)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo "❌ No list opened."
      exit 1
    fi

    print_mascot
    echo
    echo "Check     Task                  Due Date"
    echo "----------------------------------------"
    i=1
    while IFS= read -r line; do
      CHECK=$(echo "$line" | cut -d']' -f1)']'
      TASK=$(echo "$line" | cut -d']' -f2 | cut -d'|' -f1)
      DATE=$(echo "$line" | cut -d'|' -f2)
      printf "%-3s      %-20s | %s\n" "$CHECK" "$TASK" "$DATE"
      ((i++))
    done < "$(cat $CURRENT_FILE)"
    ;;
  *)
    echo "Usage:"
    echo "  sl new \"List Name\""
    echo "  sl open \"List Name\""
    echo "  sl add \"Task\" \"Jul 5\""
    echo "  sl done 1"
    echo "  sl view"
    ;;
esac
