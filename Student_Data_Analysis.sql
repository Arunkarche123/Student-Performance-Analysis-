select top 5 * from student;

--Q1. How many students are present in the dataset?
select count(*) as Toatl_student from student;

--Q2. How many students belong to each department?
select department , count(*) as total_student from student group by department order by total_student desc; --one extra

--Q3. What is the average CGPA of students in each department?
select department , round(avg(current_cgpa),2) as average_cgpa from student
group by department 
order by average_cgpa desc; --why round used and without round any change?

--Q4. What is the average attendance percentage of students in each department?
select department, round(avg(attendance_percentage),2) as avg_attend from student
group by department 
order by avg_attend;

--Q5. Which students currently have active backlogs?
select student_id, academic_year, department, current_cgpa, active_backlogs from student
where active_backlogs >0 
order by active_backlogs desc;

--Q6. Which departments have the highest number of backlogs?
select department, sum(active_backlogs) as total_b from student group by department order by total_b desc;

--Q7. What is the distribution of students based on academic status?
select academic_status, count(*) as total_stud from student group by academic_status order by total_stud desc;

--Q8. How many students have completed internships?
select internship_status, count(*) as total_int from student group by internship_status;

--Q9. Which internship domains are most popular among students?
select internship_domain, count(*) as tot_int from student
where internship_status='Yes'
group by internship_domain
order by tot_int desc;

--Q10. What is the average number of certifications completed by students in each academic year?
select admission_year, round(avg(certification_count),2) as cert_count from student -- why round?
group by admission_year
order by cert_count desc;

--Q11. Who are the top 10 students based on CGPA?
select top 10 student_id, department, current_cgpa, attendance_percentage from student
order by current_cgpa desc, attendance_percentage desc; -- why you take both desc values?

--Q12. Which students are academically at risk?
select student_id, department, current_cgpa, active_backlogs, attendance_percentage, academic_status from student
where academic_status='Average'
order by current_cgpa desc; --risk aplya category madhe nhavti te kay ghetal tya thikani

--Q13. Which departments have the highest average placement package?
select department , round(avg(placement_package_lpa),3) as avg_lpa from student 
where placement_status='Placed'
group by department
order by avg_lpa desc;

--Q14. What percentage of students are placed?
select round(
	(count(case
				when placement_status ='Placed' 
				then 1 
			end) *100)/ count(*),
	2
	) as placement_percentage
from student;

--Q15. Which companies hired the highest number of students?
select placement_company, count(*) as total_students from student
where placement_status='Placed'
group by placement_company
order by total_students desc;

--Q16. Which students have both excellent attendance and excellent academic performance?
select student_id,department,current_cgpa,attendance_percentage from student
where current_cgpa >= 8 and attendance_percentage >= 90 and active_backlogs =0
order by current_cgpa desc;

--Q17. What is the average CGPA according to attendance category?
select attendance_category, round(avg(current_cgpa),2) as avg_cgpa from student
group by attendance_category
order by avg_cgpa desc;

--Q18. Which skill level category has the highest average CGPA?
select skill_level , round(avg(current_cgpa),2) as avg_cgpa from student
group by skill_level
order by avg_cgpa desc;

--Q19. Which project domains are most commonly chosen by students?
select project_domain, count(*) as total_students from student
group by project_domain
order by total_students desc;

--Q20. Which students have completed the highest number of certifications?
select top 10
	student_id, department,certification_count, current_cgpa from student
order by certification_count desc,
	current_cgpa desc; --why taking 10 or two order by columns

--Q21. Which departments perform above the overall average CGPA?
select department, round(avg(current_cgpa),2) as avg_cgpa from student 
group by department
having avg(current_cgpa)>
( select avg(current_cgpa)
	from student
	) -- average CGPA kiti ahe overall?

--Q22. Rank students within each department by CGPA.
select
	student_id,
	department, 
	current_cgpa,
	DENSE_RANK() over ( partition by department  order by current_cgpa desc) as de_rank
from student; --why it shows like all records? any alternate way to describe it ? top10 records from all dept?

--Q23. Identify the top 3 students from each department.
WITH ranked_students AS
(
    SELECT
        student_id,
        department,
        current_cgpa,
        ROW_NUMBER() OVER
        (
            PARTITION BY department
            ORDER BY current_cgpa DESC
        ) AS rn
    FROM student
)

SELECT *
FROM ranked_students
WHERE rn <= 3;

--Q24. Which departments have poor attendance despite good CGPA?
SELECT
    department,
    ROUND(AVG(current_cgpa),2) AS avg_cgpa,
    ROUND(AVG(attendance_percentage),2) AS avg_attendance
FROM student
GROUP BY department
HAVING AVG(current_cgpa) >= 7.5
   AND AVG(attendance_percentage) > 75 ; -- why you changes sign?

--Q25. Categorize students into performance bands using CASE.
SELECT
    CASE
        WHEN current_cgpa >= 8 THEN 'High Performer'
        WHEN current_cgpa >= 6 THEN 'Moderate Performer'
        ELSE 'Needs Attention'
    END AS performance_band,
    COUNT(*) AS total_students
FROM student
GROUP BY
    CASE
        WHEN current_cgpa >= 8 THEN 'High Performer'
        WHEN current_cgpa >= 6 THEN 'Moderate Performer'
        ELSE 'Needs Attention'
    END;

--Q26. Which students perform above their department average?
SELECT
    s.student_id,
    s.department,
    s.current_cgpa
FROM student s
WHERE s.current_cgpa >
(
    SELECT AVG(current_cgpa)
    FROM student
    WHERE department = s.department
);

--Q27. Divide students into CGPA quartiles.
SELECT
    student_id,
    current_cgpa,
    NTILE(4) OVER
    (
        ORDER BY current_cgpa DESC
    ) AS cgpa_quartile
FROM student; --not understood?

--Q28. Find internship domains with above-average participation.
WITH domain_counts AS
(
    SELECT
        internship_domain,
        COUNT(*) AS students_count
    FROM student
    WHERE internship_status = 'Yes'
    GROUP BY internship_domain
)

SELECT *
FROM domain_counts
WHERE students_count >
(
    SELECT AVG(students_count)
    FROM domain_counts
);

--Q29. Calculate placement rate department-wise.
SELECT department,ROUND(COUNT(
            CASE
                WHEN placement_status='Placed'
                THEN 1
            END
        ) * 100.0 / COUNT(*),2) AS placement_rate
FROM student
GROUP BY department
ORDER BY placement_rate DESC; -- why result not given only two digits from decimal after query?

--Q30. Create a risk score combining multiple factors.
SELECT
    student_id,
    department,
    current_cgpa,
    attendance_percentage,
    active_backlogs,

    CASE
        WHEN current_cgpa < 6
             AND attendance_percentage < 75
             AND active_backlogs > 0
        THEN 'High Risk'

        WHEN current_cgpa < 7
             OR active_backlogs > 0
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS risk_level

FROM student; -- we have already created risk level factor but in this we have calculated multiple factors and finded combining result...