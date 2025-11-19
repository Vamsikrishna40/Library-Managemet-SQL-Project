
# 📚 Library Management System — SQL Project
[https://github.com/Vamsikrishna40/Library-Managemet-SQL-Project/blob/main/LIbrary%20Management.png]
## 📝 Project Summary
This project is a **fully relational Library Management System** built using **MySQL**.  
It manages:

- Publishers  
- Books  
- Authors  
- Library branches  
- Borrowers  
- Book copies per branch  
- Book loans  

It includes:

- A complete SQL schema  
- Sample queries  
- CSV datasets  
- A PPT with ER diagrams & use-case problems  
- Real-world scenarios like overdue books, inventory per branch, borrower activity, etc.

---

## 📂 Files Included

### **Main SQL File**
- `/mnt/data/LIBRARY SQL Project.sql`

### **PPT Presentation**
- `/mnt/data/Library Management.pptx`

### **Dataset CSV Files**
- `/mnt/data/publisher.csv`
- `/mnt/data/books.csv`
- `/mnt/data/authors.csv`
- `/mnt/data/book copies.csv`
- `/mnt/data/book loans.csv`
- `/mnt/data/borrower.csv`
- `/mnt/data/library branch.csv`

---

## 🏗️ Database Schema Overview

### **1. tbl_publisher**
| Column | Type | Description |
|--------|------|-------------|
| publisher_PublisherName | VARCHAR(255) PK | Publisher name |
| publisher_PublisherAddress | TEXT | Address |
| publisher_PublisherPhone | VARCHAR(15) | Phone number |

---

### **2. tbl_book**
| Column | Type |
|--------|------|
| book_BookID | INT PK AUTO_INCREMENT |
| book_Title | VARCHAR(255) |
| book_PublisherName | VARCHAR(255) FK → tbl_publisher |

---

### **3. tbl_library_branch**
| Column | Type |
|--------|------|
| library_branch_BranchID | INT PK AUTO_INCREMENT |
| library_branch_BranchName | VARCHAR(255) |
| library_branch_BranchAddress | TEXT |

---

### **4. tbl_borrower**
| Column | Type |
|--------|------|
| borrower_CardNo | INT PK AUTO_INCREMENT |
| borrower_BorrowerName | VARCHAR(255) |
| borrower_BorrowerAddress | TEXT |
| borrower_BorrowerPhone | VARCHAR(15) |

---

### **5. tbl_book_authors**
| Column | Type |
|--------|------|
| book_authors_AuthorID | INT PK AUTO_INCREMENT |
| book_authors_BookID | INT FK → tbl_book |
| book_authors_AuthorName | VARCHAR(255) |

---

### **6. tbl_book_copies**
| Column | Type |
|--------|------|
| book_copies_CopiesID | INT PK AUTO_INCREMENT |
| book_copies_BookID | INT FK → tbl_book |
| book_copies_BranchID | INT FK → tbl_library_branch |
| book_copies_No_Of_Copies | INT |

---

### **7. tbl_book_loans**
| Column | Type |
|--------|------|
| book_loans_LoansID | INT PK AUTO_INCREMENT |
| book_loans_BookID | INT FK → tbl_book |
| book_loans_BranchID | INT FK → tbl_library_branch |
| book_loans_CardNo | INT FK → tbl_borrower |
| book_loans_DateOut | DATE |
| book_loans_DueDate | DATE |

---

## ⚙️ Indexes Used
- `idx_book_title`  
- `idx_copies_bookid`  
- `idx_loans_cardno`

---

## ▶️ How to Run the Project (MySQL)

### **1. Load the SQL file**
```sql
SOURCE /mnt/data/LIBRARY SQL Project.sql;

Import CSV files (example)
LOAD DATA LOCAL INFILE '/mnt/data/publisher.csv'
INTO TABLE tbl_publisher
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(publisher_PublisherName, publisher_PublisherAddress, publisher_PublisherPhone);

Copies of "The Lost Tribe" at Sharpstown
SELECT book_copies_No_Of_Copies
FROM tbl_book_copies bc
JOIN tbl_book b ON bc.book_copies_BookID = b.book_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe'
  AND lb.library_branch_BranchName = 'Sharpstown';

Borrowers with ZERO loans
SELECT br.borrower_BorrowerName, br.borrower_CardNo
FROM tbl_borrower br
LEFT JOIN tbl_book_loans bl ON br.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;

Borrowers with more than 5 books
SELECT br.borrower_BorrowerName, br.borrower_BorrowerAddress, COUNT(*) AS BooksCheckedOut
FROM tbl_borrower br
JOIN tbl_book_loans bl ON br.borrower_CardNo = bl.book_loans_CardNo
GROUP BY br.borrower_CardNo
HAVING COUNT(*) > 5;


Total loans per branch
SELECT lb.library_branch_BranchName,
       COUNT(bl.book_loans_BookID) AS TotalLoans
FROM tbl_library_branch lb
LEFT JOIN tbl_book_loans bl 
  ON bl.book_loans_BranchID = lb.library_branch_BranchID
GROUP BY lb.library_branch_BranchName;


Books by Stephen King available at Central Branch
SELECT b.book_Title,
       COALESCE(SUM(bc.book_copies_No_Of_Copies), 0) AS CopiesAtCentral
FROM tbl_book b
JOIN tbl_book_authors ba ON b.book_BookID = ba.book_authors_BookID
LEFT JOIN tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
LEFT JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE ba.book_authors_AuthorName = 'Stephen King'
  AND lb.library_branch_BranchName = 'Central'
GROUP BY b.book_Title;

library-management-sql/
├── README.md                     # Project README (markdown) — generated
├── docs/
│   ├── ER_diagram.png             # ER diagram export from PPT (optional)
│   ├── Library_Management.pptx    # Presentation (uploaded)
│   └── schema_overview.md         # Short schema notes & diagrams
├── sql/
│   ├── LIBRARY SQL Project.sql    # Main SQL file (uploaded)
│   ├── init_schema.sql            # (optional) cleaned schema file
│   ├── load_data.sql              # (optional) CSV import / LOAD DATA statements
│   └── stored_procedures.sql      # (optional) checkout/return procedures
├── data/
│   ├── publisher.csv
│   ├── books.csv
│   ├── authors.csv
│   ├── "book copies.csv"
│   ├── "book loans.csv"
│   ├── borrower.csv
│   └── "library branch.csv"
├── scripts/
│   ├── import_csvs.sh            # Shell script to import all CSVs
│   ├── migrate_publishers.sql    # Migration script (text PK -> int PK)
│   └── backups/
│       └── sample_backup.sql
├── api/                          # Optional: sample API to interact with DB
│   ├── app.py                    # Flask example endpoints
│   └── requirements.txt
├── ui/                           # Optional: simple frontend (React/Vite)
│   └── README_UI.md
├── tests/
│   ├── test_schema.sql
│   └── test_loans.py
├── assets/
│   ├── cover_banner.png          # Project banner / cover image (to be generated)
│   └── logo.png
├── LICENSE
└── .gitignore
