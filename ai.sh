#!/bin/bash

API_KEY="....What?.. The key? Get your bruh."
ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY"

set +m
timestamp=$(date +'%Y-%m-%dT%H-%M-%S')
filename="$HOME/.config/bashscripts/chats/$timestamp.txt"
mkdir -p "$(dirname "$filename")"
touch "$filename"

while true; do
    # Read user input
    read -rp "🧿 >> " prompt

    # Check for exit
    if [[ "$prompt" == "exit" || "$prompt" == "ex" ]]; then
        break
    fi
    response_file=$(mktemp)
    previous_chats=$(<"$filename")
    modified_prompt=$(printf "New Question \n%s (reply concisely if possible) \n\nPrevious chat context \n%s" "$prompt" "$previous_chats")

    (
        curl -s "$ENDPOINT" \
        -H "Content-Type: application/json" \
       -X POST \
        -d "$(jq -n --arg modified_prompt "$modified_prompt" '{"contents": [{"parts": [{"text": $modified_prompt}]}]}')" \
       > "$response_file"
    ) &
        
    pid=$!
    
    spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    i=0
    echo -n "...."
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 100 ))
        printf "\r${spin:$i:1}${spin:$i:1}${spin:$i:1}${spin:$i:1}"
        sleep 0.2
    done
    clear
    wait "$pid" 2>/dev/null

    # saving resp
    response=$(jq -r '.candidates[0].content.parts[0].text' "$response_file")
    filedata=$(
      printf "\nQuestion: %s\nAnswer: %s\n\n" "$prompt" "$response"
   )
    
    echo -e "$filedata" >> "$filename"

    printf "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
    echo "**$prompt**" | glow
    jq -r '.candidates[0].content.parts[0].text' < "$response_file" | glow 
    echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •"
    rm "$response_file"
done
