CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- Publishers
CREATE TABLE IF NOT EXISTS tbl_publisher (
  publisher_PublisherName VARCHAR(255) PRIMARY KEY,
  publisher_PublisherAddress TEXT,
  publisher_PublisherPhone VARCHAR(15)
);

-- Books
CREATE TABLE IF NOT EXISTS tbl_book (
  book_BookID INT PRIMARY KEY AUTO_INCREMENT,
  book_Title VARCHAR(255),
  book_PublisherName VARCHAR(255),
  FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);

-- Library branches
CREATE TABLE IF NOT EXISTS tbl_library_branch (
  library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
  library_branch_BranchName VARCHAR(255),
  library_branch_BranchAddress TEXT
);

-- Borrowers
CREATE TABLE IF NOT EXISTS tbl_borrower (
  borrower_CardNo INT PRIMARY KEY AUTO_INCREMENT,
  borrower_BorrowerName VARCHAR(255),
  borrower_BorrowerAddress TEXT,
  borrower_BorrowerPhone VARCHAR(15)
);

-- Book authors
CREATE TABLE IF NOT EXISTS tbl_book_authors (
  book_authors_BookID INT,
  book_authors_AuthorName VARCHAR(255),
  book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
  FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);

-- Book copies
CREATE TABLE IF NOT EXISTS tbl_book_copies (
  book_copies_BookID INT,
  book_copies_BranchID INT,
  book_copies_No_Of_Copies INT,
  book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
  FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID),
  FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
);

-- Book loans
CREATE TABLE IF NOT EXISTS tbl_book_loans (
  book_loans_BookID INT,
  book_loans_BranchID INT,
  book_loans_CardNo INT,
  book_loans_DateOut DATE,
  book_loans_DueDate DATE,
  book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
  FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
  FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID),
  FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
);

select * from tbl_book_loans;

CREATE INDEX idx_book_title ON tbl_book(book_Title);
CREATE INDEX idx_copies_bookid ON tbl_book_copies(book_copies_BookID);
CREATE INDEX idx_loans_cardno ON tbl_book_loans(book_loans_CardNo);


--- Sample Queries for Validation
--- Check distinct book titles:
SELECT DISTINCT book_Title FROM tbl_book;

--- Check library branch names:
SELECT DISTINCT library_branch_BranchName FROM tbl_library_branch;

--- Question: How many copies of "The Lost Tribe" does Sharpstown own?

SELECT book_copies_No_Of_Copies
FROM tbl_book_copies bc
JOIN tbl_book b ON bc.book_copies_BookID = b.book_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe'
  AND lb.library_branch_BranchName = 'Sharpstown';

select * from tbl_book_copies;
SHOW COLUMNS FROM tbl_book_copies;
 
 --- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
 
SELECT lb.library_branch_BranchName, bc.book_copies_No_Of_Copies
FROM tbl_book_copies bc
JOIN tbl_book b ON bc.book_copies_BookID = b.book_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe';

--- Retrieve the names of all borrowers who do not have any books checked out.

SELECT br.borrower_BorrowerName, br.borrower_CardNo
FROM tbl_borrower br
LEFT JOIN tbl_book_loans bl ON br.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;


--- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

SELECT DISTINCT library_branch_BranchName FROM tbl_library_branch;
SELECT 
    b.book_Title,
    br.borrower_BorrowerName,
    br.borrower_BorrowerAddress,
    bl.book_loans_DueDate,
    lb.library_branch_BranchName
FROM tbl_book_loans bl
JOIN tbl_book b ON bl.book_loans_BookID = b.book_BookID
JOIN tbl_borrower br ON bl.book_loans_CardNo = br.borrower_CardNo
JOIN tbl_library_branch lb ON bl.book_loans_BranchID = lb.library_branch_BranchID
WHERE lb.library_branch_BranchName LIKE '%Sharpstown%';

--- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

SELECT lb.library_branch_BranchName,
       COUNT(bl.book_loans_BookID) AS TotalLoans
FROM tbl_library_branch lb
LEFT JOIN tbl_book_loans bl 
  ON bl.book_loans_BranchID = lb.library_branch_BranchID
GROUP BY lb.library_branch_BranchName;

--- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

SELECT br.borrower_BorrowerName, br.borrower_BorrowerAddress, COUNT(*) AS BooksCheckedOut
FROM tbl_borrower br
JOIN tbl_book_loans bl ON br.borrower_CardNo = bl.book_loans_CardNo
GROUP BY br.borrower_CardNo, br.borrower_BorrowerName, br.borrower_BorrowerAddress
HAVING COUNT(*) > 5;

--- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

SELECT 
    b.book_Title,
    COALESCE(SUM(bc.book_copies_No_Of_Copies), 0) AS CopiesAtCentral
FROM tbl_book b
JOIN tbl_book_authors ba ON b.book_BookID = ba.book_authors_BookID
LEFT JOIN tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
LEFT JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE ba.book_authors_AuthorName = 'Stephen King'
  AND lb.library_branch_BranchName = 'Central'
GROUP BY b.book_Title;
