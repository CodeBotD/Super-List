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

show_help() {
  echo "Usage:"
  echo "  sl new \"List Name\"             - Create a new list"
  echo "  sl open \"List Name\"            - Open an existing list"
  echo "  sl add \"Task\" \"Due Date\"      - Add a task with due date"
  echo "  sl done <task number>           - Mark task done"
  echo "  sl remove <task number>         - Remove a task from current list"
  echo "  sl view                        - View current list"
  echo "  sl tl remove \"List Name\"       - Delete a whole list"
  echo
}

remove_task() {
  if [ ! -f "$CURRENT_FILE" ]; then
    echo "❌ No list opened."
    exit 1
  fi

  task_num=$1
  file="$(cat $CURRENT_FILE)"

  # Check if task_num is valid positive number
  if ! [[ "$task_num" =~ ^[0-9]+$ ]]; then
    echo "❌ Task number must be a positive integer."
    exit 1
  fi

  # Check number of lines in file
  total_lines=$(wc -l < "$file")
  if [ "$task_num" -gt "$total_lines" ] || [ "$task_num" -lt 1 ]; then
    echo "❌ Task number $task_num does not exist."
    exit 1
  fi

  # Remove the line for the task
  # For macOS sed -i needs the empty '' arg
  sed -i '' "${task_num}d" "$file" && echo "🗑️ Removed task #$task_num." || echo "❌ Failed to remove task."
}

remove_list() {
  list_name=$1
  list_file="$SUPERLIST_DIR/$list_name.txt"

  if [ -z "$list_name" ]; then
    echo "❌ Please provide a list name to remove."
    exit 1
  fi

  if [ ! -f "$list_file" ]; then
    echo "❌ List \"$list_name\" does not exist."
    exit 1
  fi

  rm "$list_file" && echo "🗑️ Removed list \"$list_name\"." || echo "❌ Failed to remove list."
  # If current opened list was this one, clear CURRENT_FILE
  if [ "$(cat $CURRENT_FILE 2>/dev/null)" == "$list_file" ]; then
    rm "$CURRENT_FILE"
  fi
}

case "$1" in
  new)
    if [ -z "$2" ]; then
      echo "❌ Please provide a name for the new list."
      exit 1
    fi
    FILENAME="$SUPERLIST_DIR/$2.txt"
    if [ -f "$FILENAME" ]; then
      echo "❌ List \"$2\" already exists."
      exit 1
    fi
    touch "$FILENAME"
    echo "$FILENAME" > "$CURRENT_FILE"
    echo "✅ Created and opened \"$2\"."
    ;;
  open)
    if [ -z "$2" ]; then
      echo "❌ Please provide a list name to open."
      exit 1
    fi
    FILENAME="$SUPERLIST_DIR/$2.txt"
    if [ -f "$FILENAME" ]; then
      echo "$FILENAME" > "$CURRENT_FILE"
      echo "✅ Opened \"$2\"."
    else
      echo "❌ List \"$2\" doesn't exist."
      exit 1
    fi
    ;;
  add)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo "❌ No list opened. Use 'sl open <name>'."
      exit 1
    fi
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "❌ Usage: sl add \"Task\" \"Due Date\""
      exit 1
    fi
    echo "[ ] $2 | $3" >> "$(cat $CURRENT_FILE)"
    echo "✅ Added: $2 (Due $3)"
    ;;
  done)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo "❌ No list opened."
      exit 1
    fi
    task_num=$2
    file="$(cat $CURRENT_FILE)"
    if ! [[ "$task_num" =~ ^[0-9]+$ ]]; then
      echo "❌ Task number must be a positive integer."
      exit 1
    fi
    total_lines=$(wc -l < "$file")
    if [ "$task_num" -gt "$total_lines" ] || [ "$task_num" -lt 1 ]; then
      echo "❌ Task number $task_num does not exist."
      exit 1
    fi
    # Mark task done by replacing [ ] with [x] on that line
    # Mac sed syntax:
    sed -i '' "${task_num}s/\\[ \\]/[x]/" "$file" && echo "✔️ Marked task #$task_num as done!" || echo "❌ Failed to mark task done."
    ;;
  remove)
    if [ -z "$2" ]; then
      echo "❌ Please provide task number to remove."
      exit 1
    fi
    remove_task "$2"
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
  tl)
    if [ "$2" == "remove" ]; then
      if [ -z "$3" ]; then
        echo "❌ Please provide a list name to remove."
        exit 1
      fi
      remove_list "$3"
    else
      echo "❌ Unknown 'tl' command."
      show_help
      exit 1
    fi
    ;;
  *)
    show_help
    ;;
esac
