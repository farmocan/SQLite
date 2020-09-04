--основные показатели

--переименовать
ALTER TABLE questions RENAME COLUMN text TO my_text

-- табл p
CREATE TABLE `p_table` (`id` char , `my_text` text , `cor` INT, `n` INT, `p` INT);
INSERT INTO `p_table`
SELECT answ.id_question AS id, que.my_text, SUM(answ.correct) AS cor, COUNT(answ.correct) AS n, SUM(answ.correct) * 1.0 / COUNT(answ.correct) AS p
FROM answers answ 
INNER JOIN questions que ON que.id = answ.id_question
GROUP BY id_question;


-- для табл d: узнать СИЛЬНЫХ и СЛАБЫХ студ, 25% с начала табл и с конца табл, у них посчитать p, разность p == d вопроса
CREATE TABLE grade_students (`id_student` char , `cor` INT);
INSERT INTO grade_students
SELECT id_student, SUM(correct) AS cor
FROM answers
GROUP BY id_student
ORDER BY cor; --важно

-- начало + конец 
SELECT round(COUNT(id_student) * .25) AS students_25 FROM grade_students;
SELECT COUNT(id_student) - round(COUNT(id_student) * .25) AS last_students_25 FROM grade_students;


CREATE TABLE grade_L (`L` char);
INSERT INTO grade_L 
SELECT id_student AS L FROM grade_students LIMIT (SELECT round(COUNT(id_student) * .25) AS students_25 FROM grade_students);
SELECT * FROM grade_L;
------

CREATE TABLE grade_H (`H` char);
INSERT INTO grade_H 
SELECT id_student AS H FROM grade_students LIMIT (SELECT round(COUNT(id_student) * .25) AS students_25 FROM grade_students) OFFSET (SELECT COUNT(id_student) - round(COUNT(id_student) * .25) AS last_students_25 FROM grade_students);
SELECT * FROM grade_H;
-------


--if statement

CREATE TABLE group_answers (`id_question` char, `id_student` char, `correct` INT, cat char);
iNSERT INTO group_answers 
SELECT id_question, 
	   id_student,
	   correct,
	   CASE 
	   WHEN id_student IN (SELECT L FROM grade_L) THEN "L"
	   WHEN id_student IN (SELECT H FROM grade_H) THEN "H"
	   ELSE "others"
	   END AS cat
	   FROM answers;

--

CREATE TABLE group_p (`id` char, `cat` char, `cor` INT, `n` INT, `p` INT);
INSERT INTO group_p 
SELECT id_question AS id, cat, SUM(correct) AS cor, COUNT(correct) AS n, SUM(correct) * 1.0 / COUNT(correct) AS p
FROM group_answers
GROUP BY id_question, cat;

--сильные студ
CREATE TABLE group_H (`id` char, `cat` char, `cor` INT, `n` INT, `p` INT);
INSERT INTO group_H 
SELECT * 
FROM group_p 
WHERE cat = "H";

--слаб студ
CREATE TABLE group_L (`id` char, `cat` char, `cor` INT, `n` INT, `p` INT);
INSERT INTO group_L 
SELECT * 
FROM group_p 
WHERE cat = "L";

--
SELECT * FROM group_H;
SELECT * FROM questions;

DROP TABLE d_result; 
CREATE TABLE d_result (`id` INT, `H_p` INT, `L_p` INT);
INSERT INTO d_result 
SELECT H.id, H.p AS H_p, L.p AS L_P
FROM group_H H
INNER JOIN group_L L ON H.id = L.id;


SELECT * FROM d_result;

CREATE TABLE d_result_PURE (`id` INT, `d` INT);
INSERT INTO d_result_PURE 
SELECT id, H_p - L_P AS d 
FROM d_result
ORDER BY id;

SELECT * FROM d_result_PURE;

CREATE TABLE d_table (`id` INT, `my_text` char, `d` INT);
INSERT INTO d_table
SELECT d_result_PURE.id,  questions.my_text, d_result_PURE.d FROM d_result_PURE
JOIN questions ON d_result_PURE.id = questions.id;











