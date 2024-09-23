#!/bin/bash

# Define the SQLite database file
DB_FILE="$HOME/notes.db"

# Function to escape single quotes for SQLite
escape_string() {
    echo "$1" | sed "s/'/''/g"
}

# Function to initialize the database and table if it doesn't exist
initialize_db() {
    sqlite3 $DB_FILE "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT);"
}

# Function to add a new note
add_note() {
    title=$(zenity --entry --title="Add Note" --text="Enter the note title:" --width=800 --height=600)
    
    if [[ -z "$title" ]]; then
        zenity --error --text="Title cannot be empty." --title="Error"
        return
    fi

    content=$(zenity --text-info --editable --title="Add Note Content" --text="Enter the note content:" --width=800 --height=600)

    if [[ -z "$content" ]]; then
        zenity --error --text="Content cannot be empty." --title="Error"
        return
    fi

    # Escape single quotes in title and content for SQLite
    title=$(escape_string "$title")
    content=$(escape_string "$content")

    sqlite3 $DB_FILE "INSERT INTO notes (title, content) VALUES ('$title', '$content');"
    zenity --info --text="Note added!" --title="Success" --width=800 --height=600
}

# Function to view note titles and content
view_titles() {
    titles=$(sqlite3 $DB_FILE "SELECT id, title, content FROM notes;")
    
    if [[ -z "$titles" ]]; then
        zenity --info --text="No notes available." --title="Note Titles" --width=800 --height=600
        return
    fi

    IFS=$'\n'
    title_list=()
    for line in $titles; do
        id=$(echo "$line" | cut -d'|' -f1)
        title=$(echo "$line" | cut -d'|' -f2)
        content=$(echo "$line" | cut -d'|' -f3)
        title_list+=("$id" "$title" "$content")
    done

    selected=$(zenity --list --title="Note Titles" --column="ID" --column="Title" --column="Content" --width=800 --height=600 "${title_list[@]}")
    
    if [[ -n "$selected" ]]; then
        selected_id=$(echo "$selected" | cut -d'|' -f1)
        selected_title=$(echo "$selected" | cut -d'|' -f2)
        selected_content=$(echo "$selected" | cut -d'|' -f3)

        zenity --list --title="Note Details" --column="Field" --column="Value" \
            --width=800 --height=600 \
            "ID" "$selected_id" \
            "Title" "$selected_title" \
            "Content" "$selected_content"
    fi
}

# Function to view a specific note by ID
view_note_by_id() {
    note_id=$(zenity --entry --title="View Note" --text="Enter the note ID:" --width=800 --height=600)
    
    if [[ -z "$note_id" ]]; then
        zenity --error --text="ID cannot be empty." --title="Error"
        return
    fi

    note=$(sqlite3 $DB_FILE "SELECT title, content FROM notes WHERE id=$note_id;" | awk -F'|' '{print $1 "\n" $2}')
    
    if [[ -z "$note" ]]; then
        zenity --error --text="Note not found." --title="Error"
        return
    fi

    title=$(echo "$note" | head -n 1)
    content=$(echo "$note" | tail -n 1)

    zenity --list --title="Note Details" --column="Field" --column="Value" \
        --width=800 --height=600 \
        "Title" "$title" \
        "Content" "$content"
}

# Function to update a note by ID
update_note() {
    note_id=$(zenity --entry --title="Update Note" --text="Enter the note ID to update:" --width=800 --height=600)
    
    if [[ -z "$note_id" ]]; then
        zenity --error --text="ID cannot be empty." --title="Error"
        return
    fi

    new_title=$(zenity --entry --title="Update Note" --text="Enter the new title:" --width=800 --height=600)
    
    if [[ -z "$new_title" ]]; then
        zenity --error --text="Title cannot be empty." --title="Error"
        return
    fi
    
    new_content=$(zenity --text-info --editable --title="Update Note Content" --text="Enter the new content:" --width=800 --height=600)
    
    if [[ -z "$new_content" ]]; then
        zenity --error --text="Content cannot be empty." --title="Error"
        return
    fi
    
    # Escape single quotes in title and content for SQLite
    new_title=$(escape_string "$new_title")
    new_content=$(escape_string "$new_content")

    sqlite3 $DB_FILE "UPDATE notes SET title='$new_title', content='$new_content' WHERE id=$note_id;"
    zenity --info --text="Note updated!" --title="Success" --width=800 --height=600
}

# Function to delete a note by ID
delete_note() {
    note_id=$(zenity --entry --title="Delete Note" --text="Enter the note ID to delete:" --width=800 --height=600)
    
    if [[ -z "$note_id" ]]; then
        zenity --error --text="ID cannot be empty." --title="Error"
        return
    fi

    sqlite3 $DB_FILE "DELETE FROM notes WHERE id=$note_id;"
    zenity --info --text="Note deleted!" --title="Success" --width=800 --height=600
}

# Function to search notes by title
search_notes() {
    search_term=$(zenity --entry --title="Search Notes" --text="Enter search term:" --width=800 --height=600)
    
    if [[ -z "$search_term" ]]; then
        zenity --error --text="Search term cannot be empty." --title="Error"
        return
    fi

    results=$(sqlite3 $DB_FILE "SELECT id, title, content FROM notes WHERE title LIKE '%$search_term%';")
    
    if [[ -z "$results" ]]; then
        zenity --info --text="No notes found for the search term '$search_term'." --title="Search Results" --width=800 --height=600
        return
    fi

    IFS=$'\n'
    search_list=()
    for line in $results; do
        id=$(echo "$line" | cut -d'|' -f1)
        title=$(echo "$line" | cut -d'|' -f2)
        content=$(echo "$line" | cut -d'|' -f3)
        search_list+=("$id" "$title" "$content")
    done

    selected=$(zenity --list --title="Search Results" --column="ID" --column="Title" --column="Content" --width=800 --height=600 "${search_list[@]}")
    
    if [[ -n "$selected" ]]; then
        selected_id=$(echo "$selected" | cut -d'|' -f1)
        selected_title=$(echo "$selected" | cut -d'|' -f2)
        selected_content=$(echo "$selected" | cut -d'|' -f3)
        
        zenity --list --title="Note Details" --column="Field" --column="Value" \
            --width=800 --height=600 \
            "ID" "$selected_id" \
            "Title" "$selected_title" \
            "Content" "$selected_content"
    fi
}

# Initialize the database if not already created
initialize_db

# Main loop to choose the action
while true; do
    action=$(zenity --list --title="Notes App" --column="Action" --text="Choose an option:" --width=800 --height=600 \
        "Add Note" "View Notes" "View Note by ID" "Update Note" "Delete Note" "Search Notes" "Exit")
    
    case "$action" in
        "Add Note") add_note ;;
        "View Notes") view_titles ;;
        "View Note by ID") view_note_by_id ;;
        "Update Note") update_note ;;
        "Delete Note") delete_note ;;
        "Search Notes") search_notes ;;
        "Exit") break ;;
        *) zenity --error --text="Invalid option" --width=800 --height=600 ;;
    esac
done
