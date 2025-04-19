# 🎓 Student Management System (SMS) – Bash Edition

Welcome to the **Student Management System**, a simple yet functional project built using **pure Bash scripting**. It’s designed for a single teacher to manage up to 20 students with features like secure login, grade/CGPA calculation, and data persistence.

> 🚀 Built with ❤️ by [Muhammad Rameez](https://www.linkedin.com/in/rameez2005/)

---

## 📋 Features

- 🔐 **Secure Login System**
  - Teacher login with password
  - Student login with Roll Number & default password (`student@last4digits`)

- 🧑‍🏫 **Teacher Functionalities**
  - Add, View, Update, Delete student records
  - Sort students by CGPA
  - List passed or failed students

- 👨‍🎓 **Student Portal**
  - View personal marks, grade, and CGPA after login

- 📁 **Data Persistence**
  - All records stored in a file (`students.txt`)

- 📊 **Auto Grade & CGPA Calculation**
  - FAST-like grading system
  - GPA calculated based on letter grade

---

## 🧠 Technologies Used

- 🐚 **Bash Shell Scripting**
- 📄 Text file (`students.txt`) for storage
- Unix commands: `awk`, `grep`, `sort`, `column`, `read`, `echo`, etc.

---

## 🛡️ Validations

- ✅ Roll Number must be a positive number and unique  
- ✅ Name must be alphabetic only  
- ✅ Marks must be between `0–100`  
- ✅ Auto-grade assignment using marks  
- ✅ Passwords validated for both roles

---

## 📦 Folder Structure

```bash
├── student-management.sh   # 🔧 Main script
├── students.txt            # 📄 Student records (auto-generated)
└── README.md               # 📘 This file
