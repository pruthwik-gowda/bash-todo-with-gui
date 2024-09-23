#!/bin/bash

# Define the SQLite database file
DB_FILE="$HOME/notes.db"

# Initialize the database if not already created
initialize_db() {
    sqlite3 $DB_FILE "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT);"
}

# Function to add a new note
add_note() {
    title=$(whiptail --inputbox "Enter the note title" 8 39 --title "Add Note" 3>&1 1>&2 2>&3)
    if [ $? = 0 ]; then
        content=$(whiptail --inputbox "Enter the note content" 12 50 --title "Add Note" 3>&1 1>&2 2>&3)
        sqlite3 $DB_FILE "INSERT INTO notes (title, content) VALUES ('$title', '$content');"
        whiptail --msgbox "Note added successfully!" 8 39 --title "Success"
    else
        whiptail --msgbox "Canceled" 8 39 --title "Canceled"
    fi
}

# Function to view note titles
view_titles() {
    note_titles=$(sqlite3 $DB_FILE "SELECT id, title FROM notes;" | awk -F'|' '{printf "%s: %s\n", $1, $2}')
    whiptail --msgbox "$note_titles" 20 50 --scrolltext --title "Note Titles"
}

# Function to view a specific note by ID
view_note_by_id() {
    note_id=$(whiptail --inputbox "Enter the note ID" 8 39 --title "View Note by ID" 3>&1 1>&2 2>&3)
    if [ $? = 0 ]; then
        note=$(sqlite3 $DB_FILE "SELECT title, content FROM notes WHERE id=$note_id;" | awk -F'|' '{printf "Title: %s\nContent: %s\n", $1, $2}')
        whiptail --msgbox "$note" 20 50 --scrolltext --title "Note Details"
    else
        whiptail --msgbox "Canceled" 8 39 --title "Canceled"
    fi
}

# Function to delete a note by ID
delete_note() {
    note_id=$(whiptail --inputbox "Enter the note ID to delete" 8 39 --title "Delete Note" 3>&1 1>&2 2>&3)
    if [ $? = 0 ]; then
        sqlite3 $DB_FILE "DELETE FROM notes WHERE id=$note_id;"
        whiptail --msgbox "Note deleted!" 8 39 --title "Success"
    else
        whiptail --msgbox "Canceled" 8 39 --title "Canceled"
    fi
}

# Function to update a note by ID
update_note() {
    note_id=$(whiptail --inputbox "Enter the note ID to update" 8 39 --title "Update Note" 3>&1 1>&2 2>&3)
    if [ $? = 0 ]; then
        new_title=$(whiptail --inputbox "Enter the new title" 8 39 --title "Update Note" 3>&1 1>&2 2>&3)
        new_content=$(whiptail --inputbox "Enter the new content" 12 50 --title "Update Note" 3>&1 1>&2 2>&3)
        sqlite3 $DB_FILE "UPDATE notes SET title='$new_title', content='$new_content' WHERE id=$note_id;"
        whiptail --msgbox "Note updated!" 8 39 --title "Success"
    else
        whiptail --msgbox "Canceled" 8 39 --title "Canceled"
    fi
}

# Function to search notes by title
search_notes() {
    search_term=$(whiptail --inputbox "Enter a title to search" 8 39 --title "Search Notes" 3>&1 1>&2 2>&3)
    if [ $? = 0 ]; then
        search_results=$(sqlite3 $DB_FILE "SELECT id, title FROM notes WHERE title LIKE '%$search_term%';" | awk -F'|' '{printf "%s: %s\n", $1, $2}')
        whiptail --msgbox "$search_results" 20 50 --scrolltext --title "Search Results"
    else
        whiptail --msgbox "Canceled" 8 39 --title "Canceled"
    fi
}

# Menu function
show_menu() {
    CHOICE=$(whiptail --title "Notes App" --menu "Choose an option" 16 50 9 \
        "1" "Add Note" \
        "2" "View All Notes" \
        "3" "View Note by ID" \
        "4" "Update Note" \
        "5" "Delete Note" \
        "6" "Search Notes" \
        "7" "Exit" 3>&2 2>&1 1>&3)

    case $CHOICE in
        1) add_note ;;
        2) view_titles ;;
        3) view_note_by_id ;;
        4) update_note ;;
        5) delete_note ;;
        6) search_notes ;;
        7) exit ;;
        *) whiptail --msgbox "Invalid option" 8 39 ;;
    esac
}

# Initialize the database
initialize_db

# Show menu in a loop
while true; do
    show_menu
done
