-- retrieve with emp_np, first_name, last_name from employees table
-- retrieve title, from_date, to_date from Title table
SELECT e.emp_no, 
e.first_name, 
e.last_name, 
ti.title, 
ti.from_date, 
ti.to_date
-- use into to create new table
INTO retirements_main
FROM employees as e
-- join both tables by PK emp_no
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no)
-- filter by our requirements for age to retire
-- want to look at only current employees born between Jan 1-1952 and Dec 31-1955
	WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;
-- export as retirement_titles.csv

-- Check the table after refresh
SELECT * FROM retirements_main;


-- we now hae duplicates for some employees... 
-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (r.emp_no) 
	r.emp_no,
	r.first_name,
	r.last_name,
	r.title
-- create a new table unique titles 
INTO unique_titles
FROM retirements_main as r
-- sort by descending order by last date
ORDER BY r.emp_no, r.to_date DESC;
-- export as unique_titles.csv

-- Check the table after refresh
SELECT * FROM unique_titles;


-- last table creation to retrieve the # of employees by most recent job title
-- and who are about to retire
SELECT COUNT(ut.title), ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title
ORDER BY count DESC;
-- export as retiring_tables.csv

-- Check the table after refresh
SELECT * FROM retiring_titles;

-- DELIVERABLE 2

-- create a query to find eligible employees for a mentorship program
SELECT DISTINCT ON (e.emp_no)
	e.emp_no,
	e.first_name, 
	e.last_name, 
	e.birth_date,
	de.from_date,
	de.to_date,
	ti.title
-- create new mentorship table
INTO emp_mentorship_eligibilty
-- create a join for employees and department employee tables for PK emp_no
FROM employees as e
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
-- create join for employees and titles tables for PK emp_no
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no)
-- filter by to_date and birth_date columns
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND (de.to_date = '9999-01-01')
ORDER BY e.emp_no, ti.from_date DESC;
-- export as mentorship_eligibility.csv

-- Check the table after refresh
SELECT * FROM emp_mentorship_eligibilty;