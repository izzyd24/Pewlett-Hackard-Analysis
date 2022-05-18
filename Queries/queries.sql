-- First query to build showing ALL eligible retirees
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';
-- output shows all people within the age ranges above

-- replicating the same but for 1952
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- replicating the same but for 1953
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

-- replicating the same but for 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

-- replicating the same but for 1955
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- narrow the eligibility search query
-- limits by AND who was hired in a specific 85-88' time period
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- since our tupled output was too long, create with count
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- ouput shows 41,380 employees who meet this condition in our query 

-- original retirement eligibility query
-- adjusted to SELECT INTO to make data into table 
-- telling postgress to save a table named retirement_info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- check out previous query output
-- confirmed, after refresh, we now see 7 tables including retirement_info
SELECT * FROM retirement_info;

DROP TABLE retirement_info;

-- Create new table for retiring employees with emp_no to set up for joins
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table, end of 7.3.2
SELECT * FROM retirement_info;

--start of 7.3.3, inner join on departments and dept-manager tables
-- return the department name and employee # from dept table
-- return the from and to dates from dept-manager table
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- use left join for retirment_info table
-- return emp #, emp name first and last, if person employed today 
-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
    ri.first_name,
ri.last_name,
    de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

-- use left join for retirment_info and dept_emp
SELECT ri.emp_no,
    ri.first_name,
    ri.last_name,
de.to_date
-- create new table to hold our new info
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
-- this is a table of current employees, add the filter with where
WHERE de.to_date = ('9999-01-01');

-- Check the table, end of 7.3.3
SELECT * FROM current_emp;

-- start of 7.3.4, employee count by dept #
SELECT COUNT(ce.emp_no), de.dept_no
-- INITIAL ERROR: Had trouble placing INTO; wanted to place after Join was ran
INTO emp_by_dept
FROM current_emp as ce
-- used left join b/c wanted all emp_no from T1
LEFT JOIN dept_emp as de
-- ON lets us see which columns we use to match data; both had emp_no
ON ce.emp_no = de.emp_no
-- groupby gives us # of emp retiring from each department
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Check the table after refresh, end of 7.3.4
SELECT * FROM emp_by_dept;

-- start of 7.3.5, create emp information listfor: 
-- emp #, last/first name, gender, salary 
-- use employees and salaries table with join on emp_no
SELECT e.emp_no,
    e.first_name,
e.last_name,
    e.gender,
    s.salary,
    de.to_date
-- using INTO to create new table for emp information
INTO emp_info
FROM employees as e
-- using inner join b/c we want only matching data from employees and salaries tables
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
-- second inner join to inlcude dept_emp table
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
-- check that for joins all filters
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 AND (de.to_date = '9999-01-01');

-- Check the table after refresh
SELECT * FROM emp_info;

-- create management list per department for: 
-- managers for each dept, emp #, first/last, start/end date empolyment 
-- looking at departments (dept_name), managers (from_date, to_date), employees (first_name, last_name)
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
-- create new manager_info table prior to joins to then export as CSV
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);

-- Check the table after refresh
SELECT * FROM manager_info;

-- create dept retirees list for: 
-- updated current_emp + employee's departments 
-- looking at departments(dept_name), employees(first_name, last_name), Dept_Emp(emp_no)
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);

-- Check the table after refresh
SELECT * FROM dept_info;




-- start of 7.3.6, sales wants a list of employees in their dept. for retirement info
-- HINT: use IN condition with the WHERE clause
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO retirement_info_sales_develop_dept

FROM current_emp as ce
LEFT JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
LEFT JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name in ('Sales', 'Development');
	

-- Check the table after refresh
SELECT * FROM retirement_info_sales_develop_dept;




