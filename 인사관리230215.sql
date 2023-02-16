SELECT *
FROM board
ORDER BY 1;

COMMIT;

--INSERT문장을 통한 Transaction
INSERT INTO departments
VALUES (70, 'Public Relations', 100, 1700);

SELECT *
FROM departments;

ROLLBACK;

SELECT * 
FROM departments;

COMMIT;

--다른 테이블로 ROW 복사 ->AUTO COMMIT
CREATE TABLE sales_reps
AS 
SELECT employee_id id, last_name name, salary, commission_pct
FROM employees;

SELECT *
FROM sales_reps;

--INSERT문 => 치환변수 사용
INSERT INTO departments (department_id, department_name, location_id)
VALUES (&department_id, '&department_name', &location);

SELECT *
FROM departments;

--UPDATE 문장을 활용한 Transaction
UPDATE employees
SET salary = 7000;

SELECT *
FROM employees;

ROLLBACK;

UPDATE employees
SET salary = 7000
WHERE employee_id = 104;
--Transaction 종료                          
ROLLBACK;   

UPDATE employees
SET salary = salary*1.1
WHERE employee_id = 104;

ROLLBACK;

SELECT *
FROM employees;

--서브쿼리를 사용한 UPDATE
UPDATE employees
SET job_id = (
              SELECT job_id
              FROM employees
              WHERE employee_id = 205),
    salary = (
              SELECT salary
              FROM employees
              WHERE employee_id = 205)
WHERE employee_id = 124;

SELECT *
FROM employees;

UPDATE employees
SET department_id = (
                     SELECT department_id
                     FROM departments
                     WHERE department_name LIKE '%Public%')
WHERE employee_id = 206;

SELECT *
FROM employees;

SELECT *
FROM departments;

ROLLBACK;

--DELETE
DELETE FROM departments
WHERE department_name = 'Finance';

DELETE FROM employees
WHERE department_id = (
                       SELECT department_id
                       FROM departments
                       WHERE department_name LIKE '%Public%');
ROLLBACK;

--TABLE DELETE & TRUNCATE - 테이블 데이터 삭제
--TABLE에서 DELETE => 데이터만 삭제
SELECT *
FROM sales_reps;

DELETE FROM sales_reps;
ROLLBACK;

--TABLE에서 TRUNCATE => 데이터와 데이터 보관하는 공간까지 삭제
TRUNCATE TABLE sales_reps;                          
ROLLBACK;                          
                          
INSERT INTO sales_reps
SELECT employee_id, last_name, salary, commission_pct
FROM employees
WHERE job_id LIKE '%REP%';

SELECT *
FROM sales_reps;

COMMIT;

DELETE FROM sales_reps
WHERE id = 174;

SAVEPOINT sp1;

DELETE FROM sales_reps
WHERE id = 202;

ROLLBACK to sp1;

ROLLBACK;

SELECT table_name
FROM user_tables;

SELECT DISTINCT object_type
FROM user_objects;

SELECT *
FROM user_catalog;

--table 생성
CREATE TABLE dept(
dept_no number(2),
dname varchar2(14),
loc varchar2(13),
create_date DATE DEFAULT sysdate);

DESC dept;

INSERT INTO dept(dept_no, dname, loc)
VALUES (1, '또', '예담');

SELECT * 
FROM dept;

CREATE TABLE dept30
AS
    SELECT employee_id, last_name, salary*12 AS "salary", hire_date
    FROM employees
    WHERE department_id = 50;

SELECT *
FROM dept30;

DESC employees;

DESC dept30;

DROP TABLE dept;
DROP TABLE dept30;

--Column 추가
ALTER TABLE dept30
ADD         (job VARCHAR2(20));

DESC dept30;

ALTER TABLE dept30
MODIFY      (job NUMBER);

INSERT INTO dept30
VALUES (1, '또치' ,2000, SYSDATE, 123);

ALTER TABLE dept30
MODIFY      (job VARCHAR2(40));

DELETE FROM dept30
WHERE employee_id = 1;

ALTER TABLE dept30
DROP COLUMN job;

DESC dept30;

ALTER TABLE dept30
SET UNUSED (hire_date);

SELECT * 
FROM dept30;

ALTER TABLE dept30
DROP UNUSED COLUMNS;

--RENAME
RENAME dept30 TO dept100;

SELECT *
FROM dept100;

COMMENT ON TABLE dept100
IS 'THIS IS DEPT100';

SELECT *
FROM all_col_comments
WHERE LOWER(table_name) = 'dept100'; --all_tab_comments

COMMENT ON COLUMN dept100.employee_id
IS 'THIS IS EMPLOYEE_ID'; --all_col_comments

SELECT *
FROM dept100;

TRUNCATE TABLE dept100;
            
ROLLBACK;--안됨

DROP TABLE dept100;

--기본키 (primary key) 기본값 열을 포함하는 테이블 생성
DROP TABLE board;

CREATE TABLE dept(
                  deptno NUMBER(2) PRIMARY KEY, --기본키
                  dname VARCHAR2(14),
                  loc VARCHAR2(13),
                  create_date DATE DEFAULT SYSDATE --기본값을 가지는 열(Column)
                  );
                  
INSERT INTO dept(deptno, dname)
VALUES (10, '기획부'); --기본값을 가지는 열(Column)에 데이터가 자동 입력

INSERT INTO dept
VALUES (20, '영업부', '서울', '23/02/15');

COMMIT;

SELECT *
FROM dept;

--여러가지 제약조건을 포함하는 테이블 생성
DROP TABLE emp;

CREATE TABLE emp(
empno NUMBER(6) PRIMARY KEY, --기본키 제약조건
ename VARCHAR2(25) NOT NULL, --NOT NULL 제약조건
email VARCHAR2(50) CONSTRAINT emp_mail_nn NOT NULL --NOT NULL 제약조건 + 제약조건 이름 부여
                   CONSTRAINT emp_mail_uk UNIQUE, -- UNIQUE 제약조건 + 제약조건 이름 부여
phone_no CHAR(11) NOT NULL,
job VARCHAR2(20),
salary NUMBER(8) CHECK(salary>2000),--CHECK 제약조건, 2000보다 큰 데이터가 들어와야 입력 가능
deptno NUMBER(4) REFERENCES dept(deptno));--FOREIGN KEY 제약조건, dept table에서 deptno라는 Column을 참조해서 데이터 입력

--CREATE TABLE emp(
----COLUMN LEVEL CONSTRAINT
--empno NUMBER(6),
--ename VARCHAR2(25) CONSTRAINT emp_ename_nn NOT NULL,
--email VARCHAR2(50) CONSTRAINT emp_email_nn NOT NULL, 
--phone_no CHAR(11),
--job VARCHAR2(20),
--salary NUMBER(8),
--deptno NUMBER(4),
--CONSTRAINT emp_empno_pk PRIMARY KEY(empno),
--CONSTRAINT emp_email_uk UNIQUE(email),
--CONSTRAINT emp_salary_ck CHECK(salary>2000),
--CONSTRAINT emp_deptno_fk FOREIGN KEY(deptno)
--REFERENCES dept(deptno)
--);

--제약조건 관련 딕셔너리 정보 보기
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'EMP';

SELECT cc.column_name, c.constraint_name
FROM user_constraints c JOIN user_cons_columns cc
ON (c.constraint_name = cc.constraint_name)
WHERE c.table_name = 'EMP';

SELECT table_name, index_name
FROM user_indexes
WHERE table_name IN('DEPT', 'EMP');

--DML을 수행하며 제약조건 테스트하기
INSERT INTO emp --empno에 null불가
VALUES(null, '또치', 'ddoChiKim@naver.com', '01023456789', '회사원', 3500, null);

INSERT INTO emp
VALUES(1234, '또치', 'ddoChiKim@naver.com', '01023456789', '회사원', 3500, null);

INSERT INTO emp--salary 2000이상
VALUES(1233, '희동', 'heeeedong@naver.com', '01054359875', '회사원',1800, 20);

INSERT INTO emp
VALUES(1233, '희동', 'heeeedong@naver.com', '01054359875','회사원', 7800, 20);

COMMIT;

INSERT INTO emp --참조확인
VALUES(1223, '희동', 'heeeedong@naver.com', '01054359875', 1800, 100);

--UPDATE
UPDATE emp
SET deptno = 30
WHERE empno = 1234;

UPDATE emp
SET deptno = 10
WHERE empno = 1234;

SELECT *
FROM emp;

ALTER TABLE emp
ADD CONSTRAINT emp_job_uk UNIQUE(job);

INSERT INTO emp 
VALUES(1200, '길동', 'gildong@naver.com', '01054359875','회사원', 5400, 20);

ALTER TABLE emp
MODIFY (salary number NOT NULL);

ALTER TABLE emp
DROP CONSTRAINT emp_job_uk;

SELECT *
FROM emp;

CREATE TABLE market(
                    mno NUMBER(5),
                    mname VARCHAR2(30),
                    maddress VARCHAR2(150),
                    mphone_no CHAR(13),
                    msales NUMBER(6) CHECK(msales>1000));
                    
CREATE TABLE product(
                     prono NUMBER(4) PRIMARY KEY,
                     pname CHAR(30),
                     pprice NUMBER(5) CHECK(pprice>100),
                     pstorage
                     mno NUMBER(5) REFERENCES market(mno));
                     

                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          