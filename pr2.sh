#!/bin/bash

# ---------------------------------------------
# Student Management System (SMS)
# Developed in Bash for a single teacher to manage up to 20 students.
# Features:
# - Secure login system for Teacher and Students
# - CRUD operations on student records (Add, View, Update, Delete)
# - Automatic Grade and CGPA Calculation
# - Students can log in to view their grades and CGPA
# - Data persistence using "students.txt"
# ---------------------------------------------

# ============================
# Constants & Global Variables
# ============================
STUDENT_FILE="students.txt"  # File to store student records
MAX_STUDENTS=20              # Maximum students allowed
PASS_CGPA=2.0                # Minimum CGPA required to pass

# ============================
# Load Students Function
# Ensures that the student records file exists, creating it if necessary.
# ============================
load_students() {
    if [[ ! -f $STUDENT_FILE ]]; then
        touch $STUDENT_FILE
    fi
}

# ============================
# Calculate Grade Function
# Determines the grade based on marks, following FAST grading criteria.
# ============================
calculate_grade() {
    local marks=$1
    if (( marks >= 90 )); then echo "A+"; 
    elif (( marks >= 85 )); then echo "A"; 
    elif (( marks >= 80 )); then echo "A-"; 
    elif (( marks >= 75 )); then echo "B+"; 
    elif (( marks >= 70 )); then echo "B"; 
    elif (( marks >= 65 )); then echo "B-"; 
    elif (( marks >= 60 )); then echo "C+"; 
    elif (( marks >= 55 )); then echo "C"; 
    elif (( marks >= 50 )); then echo "D"; 
    else echo "F"; fi
}

# ============================
# Convert Grade to GPA Function
# Converts letter grades into corresponding GPA values.
# ============================
grade_to_gpa() {
    case $1 in
        "A+") echo "4.0";;
        "A") echo "4.0";;
        "A-") echo "3.7";;
        "B+") echo "3.3";;
        "B") echo "3.0";;
        "B-") echo "2.7";;
        "C+") echo "2.3";;
        "C") echo "2.0";;
        "D") echo "1.0";;
        "F") echo "0.0";;
        *) echo "0.0";;
    esac
}

# ============================
# Add Student Function
# Allows the teacher to add a new student with marks, grade, and CGPA.
# ============================
add_student() {
    local count=$(wc -l < $STUDENT_FILE)
    if (( count >= MAX_STUDENTS )); then
        echo "Maximum student limit reached!"
        return
    fi

    read -p "Enter Roll Number: " roll
    grep -q "^$roll," $STUDENT_FILE && { echo "Student already exists!"; return; }

    read -p "Enter Name: " name
    read -p "Enter Marks: " marks

    grade=$(calculate_grade $marks)
    gpa=$(grade_to_gpa $grade)

    echo "$roll,$name,$marks,$grade,$gpa" >> $STUDENT_FILE
    echo "Student added successfully."
}

# ============================
# View All Students Function
# Displays all student records in a formatted table.
# ============================
view_all_students() {
    echo -e "Roll\tName\tMarks\tGrade\tCGPA"
    column -t -s, $STUDENT_FILE
}

# ============================
# View Student by Roll Number Function
# Allows searching for a specific student's details using Roll Number.
# ============================
view_student() {
    read -p "Enter Roll Number: " roll
    grep "^$roll," $STUDENT_FILE || echo "Student not found!"
}

# ============================
# Delete Student Function
# Removes a student record based on Roll Number.
# ============================
delete_student() {
    read -p "Enter Roll Number to delete: " roll
    grep -v "^$roll," $STUDENT_FILE > temp && mv temp $STUDENT_FILE
    echo "Student deleted (if existed)."
}

# ============================
# Update Marks Function
# Updates a student's marks and recalculates the grade and CGPA.
# ============================
update_marks() {
    read -p "Enter Roll Number: " roll
    read -p "Enter new marks: " marks

    grade=$(calculate_grade $marks)
    gpa=$(grade_to_gpa $grade)

    awk -F, -v r=$roll -v m=$marks -v g=$grade -v c=$gpa 'BEGIN{OFS=","} 
    $1==r{$3=m;$4=g;$5=c} 1' $STUDENT_FILE > temp && mv temp $STUDENT_FILE

    echo "Marks updated."
}

# ============================
# List Students by CGPA Function
# Displays students sorted in ascending or descending order of CGPA.
# ============================
list_students_by_cgpa() {
    echo "1) Ascending"
    echo "2) Descending"
    read -p "Select order: " order
    if [[ $order == 1 ]]; then
        sort -t, -k5 -n $STUDENT_FILE | column -t -s,
    else
        sort -t, -k5 -nr $STUDENT_FILE | column -t -s,
    fi
}

# ============================
# List Passed/Failed Students Function
# Displays students who have passed or failed based on CGPA.
# ============================
list_pass_fail() {
    echo "1) Passed"
    echo "2) Failed"
    read -p "Select option: " opt
    if [[ $opt == 1 ]]; then
        awk -F, -v th=$PASS_CGPA '$5 >= th' $STUDENT_FILE | column -t -s,
    else
        awk -F, -v th=$PASS_CGPA '$5 < th' $STUDENT_FILE | column -t -s,
    fi
}

# ============================
# Teacher Login Function
# Authenticates the teacher with a predefined password.
# ============================
teacher_login() {
    TEACHER_PASSWORD="fast123"  # Set teacher password

    read -s -p "Enter Password: " input_pass
    echo

    if [[ "$input_pass" == "$TEACHER_PASSWORD" ]]; then
        teacher_menu
    else
        echo "Incorrect Password!"
    fi
}

# ============================
# Student Login Function
# Authenticates students using Roll Number and default password.
# ============================
student_login() {
    read -p "Enter Your Roll Number: " roll

    student=$(grep "^$roll," $STUDENT_FILE)
    if [[ -z "$student" ]]; then
        echo "Student not found!"
        return
    fi

    last4="${roll: -4}"
    expected_pass="student@$last4"

    read -s -p "Enter Password: " input_pass
    echo

    if [[ "$input_pass" == "$expected_pass" ]]; then
        IFS=',' read -r r name marks grade gpa <<< "$student"
        echo "Name: $name"
        echo "Marks: $marks"
        echo "Grade: $grade"
        echo "CGPA: $gpa"
    else
        echo "Incorrect Password!"
    fi
}

# ============================
# Teacher Menu Function
# Provides options for managing students.
# ============================
teacher_menu() {
    while true; do
        echo -e "\n--- Teacher Menu ---"
        echo "1) Add Student"
        echo "2) View All Students"
        echo "3) View Student"
        echo "4) Update Marks"
        echo "5) Delete Student"
        echo "6) List Students by CGPA"
        echo "7) List Passed/Failed Students"
        echo "0) Logout"
        read -p "Choose: " choice

        case $choice in
            1) add_student ;;
            2) view_all_students ;;
            3) view_student ;;
            4) update_marks ;;
            5) delete_student ;;
            6) list_students_by_cgpa ;;
            7) list_pass_fail ;;
            0) break ;;
            *) echo "Invalid option." ;;
        esac
    done
}

#main_menu
main_menu() {
    clear
    # Color codes
    GREEN='\033[0;32m'
    BLUE='\033[1;34m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    # Print Banner
    echo -e "${BLUE}"
    echo "                            ______    _______     ______ "
    echo "                           / _____)  (_______)   / _____)"
    echo "                          ( (____     _  _  _   ( (____  "
    echo "                           \____ \   | ||_|| |   \____ \ "
    echo "                           _____) )  | |   | |   _____) )"
    echo "                          (______/   |_|   |_|  (______/ "
    echo -e "${GREEN}"
    echo "                   Welcome to the Student Management System"
    echo "                          Built with ❤️ by RAMEEZ"
    echo -e "${NC}"
    sleep 1

    load_students
    while true; do
        echo -e "\n🔐 ${BLUE}Main Menu:${NC}"
        echo "1) 👨‍🏫 Teacher Login"
        echo "2) 👨‍🎓 Student Login"
        echo "0) 🚪 Exit"
        read -p "Choose: " opt

        case $opt in
            1) teacher_login ;;
            2) student_login ;;
            0) echo -e "${GREEN}Goodbye!${NC}"; break ;;
            *) echo -e "${RED}Invalid option!${NC}" ;;
        esac
    done
}

# Run the main menu
main_menu
