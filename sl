#!/bin/bash

# COLORS
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CYAN='\033[36m'
RESET='\033[0m'

SUPERLIST_DIR="$HOME/.superlist"
CURRENT_FILE="$SUPERLIST_DIR/.current"

mkdir -p "$SUPERLIST_DIR"

print_mascot() {
echo -e "${BLUE}  .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-."
echo -e " / / \\ \\ / / \\ \\ / / \\ \\ / / \\ \\ / / \\ \\ / / \\ \\ / / \\ \\ / / \\ \\"
echo -e "\`-'\   \`-'\   \`-'\   \`-'\   \`-'\   \`-'\   \`-'\   \`-'\   \`-'\   \`-"
echo -e "${GREEN}"
echo -e "        Super List! 📋   with Lil’ Fishy 🐟"
echo -e "               \\_/ o\\"
echo -e "               /\\__/"
echo -e "${RESET}"
}

show_help() {
  echo -e "${CYAN}Usage:${RESET}"
  echo -e "${YELLOW}  sl new \"List Name\"${RESET}             - Create a new list"
  echo -e "${YELLOW}  sl open \"List Name\"${RESET}            - Open an existing list"
  echo -e "${YELLOW}  sl add \"Task\" \"Due Date\"${RESET}      - Add a task with due date"
  echo -e "${YELLOW}  sl done <task number>${RESET}           - Mark task done"
  echo -e "${YELLOW}  sl remove <task number>${RESET}         - Remove a task from current list"
  echo -e "${YELLOW}  sl view${RESET}                        - View current list"
  echo -e "${YELLOW}  sl tl remove \"List Name\"${RESET}       - Delete a whole list"
  echo
}

remove_task() {
  if [ ! -f "$CURRENT_FILE" ]; then
    echo -e "${RED}❌ No list opened.${RESET}"
    exit 1
  fi

  task_num=$1
  file="$(cat $CURRENT_FILE)"

  if ! [[ "$task_num" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Task number must be a positive integer.${RESET}"
    exit 1
  fi

  total_lines=$(wc -l < "$file")
  if [ "$task_num" -gt "$total_lines" ] || [ "$task_num" -lt 1 ]; then
    echo -e "${RED}❌ Task number $task_num does not exist.${RESET}"
    exit 1
  fi

  sed -i '' "${task_num}d" "$file" && echo -e "${GREEN}🗑️ Removed task #$task_num.${RESET}" || echo -e "${RED}❌ Failed to remove task.${RESET}"
}

remove_list() {
  list_name=$1
  list_file="$SUPERLIST_DIR/$list_name.txt"

  if [ -z "$list_name" ]; then
    echo -e "${RED}❌ Please provide a list name to remove.${RESET}"
    exit 1
  fi

  if [ ! -f "$list_file" ]; then
    echo -e "${RED}❌ List \"$list_name\" does not exist.${RESET}"
    exit 1
  fi

  rm "$list_file" && echo -e "${GREEN}🗑️ Removed list \"$list_name\".${RESET}" || echo -e "${RED}❌ Failed to remove list.${RESET}"
  if [ "$(cat $CURRENT_FILE 2>/dev/null)" == "$list_file" ]; then
    rm "$CURRENT_FILE"
  fi
}

case "$1" in
  new)
    if [ -z "$2" ]; then
      echo -e "${RED}❌ Please provide a name for the new list.${RESET}"
      exit 1
    fi
    FILENAME="$SUPERLIST_DIR/$2.txt"
    if [ -f "$FILENAME" ]; then
      echo -e "${RED}❌ List \"$2\" already exists.${RESET}"
      exit 1
    fi
    touch "$FILENAME"
    echo "$FILENAME" > "$CURRENT_FILE"
    echo -e "${GREEN}✅ Created and opened \"$2\".${RESET}"
    ;;
  open)
    if [ -z "$2" ]; then
      echo -e "${RED}❌ Please provide a list name to open.${RESET}"
      exit 1
    fi
    FILENAME="$SUPERLIST_DIR/$2.txt"
    if [ -f "$FILENAME" ]; then
      echo "$FILENAME" > "$CURRENT_FILE"
      echo -e "${GREEN}✅ Opened \"$2\".${RESET}"
    else
      echo -e "${RED}❌ List \"$2\" doesn't exist.${RESET}"
      exit 1
    fi
    ;;
  add)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo -e "${RED}❌ No list opened. Use 'sl open <name>'.${RESET}"
      exit 1
    fi
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo -e "${RED}❌ Usage: sl add \"Task\" \"Due Date\"${RESET}"
      exit 1
    fi
    echo "[ ] $2 | $3" >> "$(cat $CURRENT_FILE)"
    echo -e "${GREEN}✅ Added: \"$2\" (Due $3)${RESET}"
    ;;
  done)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo -e "${RED}❌ No list opened.${RESET}"
      exit 1
    fi
    task_num=$2
    file="$(cat $CURRENT_FILE)"
    if ! [[ "$task_num" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}❌ Task number must be a positive integer.${RESET}"
      exit 1
    fi
    total_lines=$(wc -l < "$file")
    if [ "$task_num" -gt "$total_lines" ] || [ "$task_num" -lt 1 ]; then
      echo -e "${RED}❌ Task number $task_num does not exist.${RESET}"
      exit 1
    fi
    sed -i '' "${task_num}s/\\[ \\]/[x]/" "$file" && echo -e "${GREEN}✔️ Marked task #$task_num as done!${RESET}" || echo -e "${RED}❌ Failed to mark task done.${RESET}"
    ;;
  remove)
    if [ -z "$2" ]; then
      echo -e "${RED}❌ Please provide task number to remove.${RESET}"
      exit 1
    fi
    remove_task "$2"
    ;;
  view)
    if [ ! -f "$CURRENT_FILE" ]; then
      echo -e "${RED}❌ No list opened.${RESET}"
      exit 1
    fi
    print_mascot
    echo
    echo -e "${CYAN}Check     Task                  Due Date${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    i=1
    while IFS= read -r line; do
      CHECK=$(echo "$line" | cut -d']' -f1)']'
      TASK=$(echo "$line" | cut -d']' -f2 | cut -d'|' -f1)
      DATE=$(echo "$line" | cut -d'|' -f2)
      printf "${GREEN}%-3s${RESET}      ${BLUE}%-20s${RESET} | ${PURPLE}%s${RESET}\n" "$CHECK" "$TASK" "$DATE"
      ((i++))
    done < "$(cat $CURRENT_FILE)"
    ;;
  tl)
    if [ "$2" == "remove" ]; then
      if [ -z "$3" ]; then
        echo -e "${RED}❌ Please provide a list name to remove.${RESET}"
        exit 1
      fi
      remove_list "$3"
    else
      echo -e "${RED}❌ Unknown 'tl' command.${RESET}"
      show_help
      exit 1
    fi
    ;;
  *)
    show_help
    ;;
esac
