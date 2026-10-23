create database Hopital_Patient_care;
use Hopital_Patient_care;


create table doctors(
doctor_id varchar(10) primary key,
doctor_name varchar(100) Not Null,
speciality varchar(50) Not Null,
hire_date Date Not Null, rating Decimal(3,2) CHECK (rating BETWEEN 0 AND 5) Not Null,
employment_type varchar(20) Not Null Default 'Full-Time',
is_active varchar(3) Not Null Default 'Yes');


create table patients(
patient_id varchar(20) primary key,
patient_name varchar(100) Not Null,
age int Not Null check(age >=0),
gender varchar(10) Not Null,
city varchar(50) Not Null, patient_type varchar(20) Not Null,
preferred_time_slot varchar(30) Not Null, registration_date Date Not Null 
);

create table appointments(appointment_id varchar(20) primary key,
patient_id varchar(20) Not Null,appointment_date Date Not Null,doctor_id varchar(10) Not Null,
service_type varchar(30) Not Null, priority varchar(10) Not Null, estimated_cost Decimal(10,2)
Not Null CHECK (estimated_cost >= 0), booking_channel varchar(20),
foreign key(patient_id) references patients(patient_id),
foreign key(doctor_id) references doctors(doctor_id)
);


create table rooms(room_id varchar(10) primary key,
room_type varchar(30) Not Null,
floor int Not Null check (floor >0), equipment_type varchar(50) Not Null,
capacity int Not Null check(capacity >0), 
last_maintenance_date date Not Null, is_available varchar(3) Not Null default 'No');


create table treatments(treatment_id varchar(20) primary key,
appointment_id varchar(20) Not Null, doctor_id varchar(10) Not Null,
room_id varchar(10) Not Null,
actual_treatment_date date Not Null,
status varchar(20) Not Null,treatment_attempt int check (treatment_attempt>0) Not Null,
treatment_duration_min int Not Null check(treatment_duration_min>0),
waiting_time_min int not Null check(waiting_time_min>=0),
treatment_cost Decimal(10,2) Not Null check (treatment_cost >0),
foreign key(appointment_id) references appointments(appointment_id),
foreign key(doctor_id) references doctors(doctor_id),
foreign key(room_id) references rooms(room_id)

);
select * from doctors;
select * from patients;

select * from rooms;
select * from appointments;
select * from treatments;

-- Sprint 3: Basic Analysis: --
-- 1. What is the total number of patients?
select count(*) from patients;
-- 2. What is the total number of appointments?
select count(*) from appointments;
-- 3. What is the total number of treatment records?
select count(*) from treatments;
-- 4. What are the different medical service types?
select distinct(service_type),count(*) from appointments group by service_type;
-- 5. How many doctors are currently active?
select count(*) from doctors where is_active='Yes';
-- 6. What are the different room types?
select distinct room_type from rooms group by room_type;
-- 7. What is the total estimated appointment value?
select sum(estimated_cost) as total_estimation from appointments;
-- 8. What is the average treatment duration?
select avg(treatment_duration_min) as avg_treatment_duration_min from treatments;

-- Sprint 4: Objective-Based Analysis
-- first looking totally into patients table.
-- 1.how many people in total with type of gender.
select gender,count(*) as no_of_patients from patients group by gender;

-- 2. gender with percentage:
select gender,count(*) as no_of_patients,
(count(gender)/(select count(*) from patients) * 100) as percentage_of_patients
 from patients group by gender;
-- same output with window() function approach

select distinct gender, (count(gender) over(partition by gender))  as no_of_patients,
(count(gender) over(partition by gender)/count(*) over() * 100) as percentage_of_patients
from patients;
-- 3. categorizing people by age:
select *,
case
when age <= 12 then "Kids"
when age between 13 and 17 then "Teenagers"
when age between 18 and 39 then "Adults"
when age between 40 and 59 then "Middle Aged"
when age >= 60 then "Senior Citizens"
else  "Unknown" 
end as age_category
from patients
;
-- 4. How are patients distributed across age groups?
select count(*) as no_of_patients ,
case
when age <= 12 then "Kids"
when age between 13 and 17 then "Teenagers"
when age between 18 and 39 then "Adults"
when age between 40 and 59 then "Middle aged"
else  "Senior Citizens" 
end as age_category
from patients group by age_category ORDER BY no_of_patients DESC;
-- 5. number of people from each city:
select city, count(*) as no_of_patients from patients group by city order by no_of_patients desc;
-- 6. number of patients from each type:
select patient_type, count(*) as no_of_patients from patients group by patient_type;
-- 7.with percentage
select distinct patient_type, count(*) over(partition by patient_type) as type_of_patients,
count(*) over(partition by patient_type)/count(*) over() *100 as type_of_patients_with_percentage
from patients;

-- 8. number of patients with time slot preference:
select preferred_time_slot,count(*) as no_of_patients from patients group by preferred_time_slot
order by no_of_patients desc; 
-- 9
select registration_date from patients;


-- 10. Compare appointment volume across cities each city with no of appointments.
select p.city,count(appointment_id) as no_of_appointments_from_city from patients p
inner join appointments a on p.patient_id = a.patient_id
group by city order by no_of_appointments_from_city desc;
-- 11. Compare appointment volume across cities each city with no of appointments with patient_type:
select p.city,p.patient_type,count(a.appointment_id) as no_of_appointments_from_city
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.city,p.patient_type order by p.city,No_of_appointments_from_city desc;
-- 
select  p.patient_id,p.patient_name,a.service_type, count(a.service_type) as no_of_consultations
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id,a.service_type ORDER BY no_of_consultations DESC;

-- each patient with no_of appointments 
select  p.patient_name, count(a.appointment_id) as no_of_appointments
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id order by no_of_appointments desc;
--  top 10 patients
select p.patient_id, p.patient_name, count(a.appointment_id) as no_of_appointments
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id order by no_of_appointments desc limit 10;
-- Which service types get the most appointments, and how are they split by priority?
select service_type,count(*) as total_appointments from appointments
group by service_type order by total_appointments desc;

-- How is appointment demand distributed across service types, and which service types have the highest share of urgent appointments?
select service_type,
count(*) as total_appointments,
SUM(CASE WHEN priority = 'High'    THEN 1 ELSE 0 END) AS high,
SUM(CASE WHEN priority = 'Urgent'  THEN 1 ELSE 0 END) AS urgent,
SUM(CASE WHEN priority = 'Routine'  THEN 1 ELSE 0 END) AS routine
from appointments
group by service_type order by total_appointments desc;

-- with percentage 

select service_type,
count(*) as total_appointments,
SUM(CASE WHEN priority = 'High'    THEN 1 ELSE 0 END) AS high,
SUM(CASE WHEN priority = 'Urgent'  THEN 1 ELSE 0 END) AS urgent,
SUM(CASE WHEN priority = 'Routine'  THEN 1 ELSE 0 END) AS routine,
(SUM(CASE WHEN priority = 'Urgent'  THEN 1 ELSE 0 END) / count(*))*100 as percentage_patient
from appointments
group by service_type order by total_appointments desc;

--
select 
priority, count(priority) from appointments
group by priority;

-- 

select appointment_date from appointments;

DESCRIBE appointments;

select min(appointment_date), max(appointment_date) from appointments;

select DATE_FORMAT(appointment_date, '%Y-%m-%d') as to_date from appointments;
--  How does appointment volume change month by month in 2025?
select
month(appointment_date) as month_no, 
monthname(appointment_date) as month_name,
count(*) from appointments
group by month(appointment_date),monthname(appointment_date)
order by month_no;

-- which patient_type this appointments are taken mostly

select p.patient_type, month(a.appointment_date),MONTHNAME(a.appointment_date), count(p.patient_type)  
from patients p inner join appointments a 
on p.patient_id = a.patient_id
group by p.patient_type,
month(a.appointment_date),MONTHNAME(a.appointment_date)
 order by p.patient_type,month(a.appointment_date);

-- How many appointments does each patient type have on each date?
select p.patient_type,
       a.appointment_date,
       count(*) as no_of_appointments
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_type, a.appointment_date
order by a.appointment_date, p.patient_type;

-- 
-- total cost for the patients:
select sum(estimated_cost) from appointments;

-- estimated total cost for each patient cost:
select p.patient_id,p.patient_name,sum(a.estimated_cost)  from patients p inner join appointments a 
on p.patient_id = a.patient_id group by p.patient_id;
-- total no_of appointment by patient_type
select p.patient_type,sum(a.estimated_cost) as total_cost_for_each_type
from patients p inner join appointments a 
on p.patient_id = a.patient_id group by p.patient_type
order by total_cost_for_each_type desc;
-- avg no_of appointment by patient_type
select p.patient_type,count(*) as no_of_appointmnts,
round(avg(a.estimated_cost),2) as avg_Cost_per_patient
from patients p inner join appointments a 
on p.patient_id = a.patient_id
group by p.patient_type order by avg_Cost_per_patient;
-- Which patient type brings the highest total and average estimated appointment value?
-- total togethwer with avg and sum
select p.patient_type,count(*) as no_of_appointments,
round(avg(a.estimated_cost),2) as avg_Cost_per_patient,
round(sum(a.estimated_cost),2) as total_estimated_cost
from patients p inner join appointments a 
on p.patient_id = a.patient_id
group by p.patient_type order by total_estimated_cost,avg_Cost_per_patient desc;

-- Who are the top 10 most frequent patients, and how much estimated value do they bring?
select p.patient_id, p.patient_name, count(a.appointment_id) as no_of_appointments,
sum(a.estimated_cost) as total_estimated_cost
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id order by no_of_appointments desc limit 10;

-- How many patients are Occasional, Regular, or Frequent bookers?
select 
p.patient_id, p.patient_name, count(a.appointment_id) as no_of_appointments,
case
when count(a.appointment_id) between 1 and 4 then "Occasional"
when count(a.appointment_id) between 5 and 9 then "Regular"
else "Frequent"
end as patient_category
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id;


-- How are patients distributed by booking frequency
--        (Occasional / Regular / Frequent)? with percentage
with patient_counts as (select 
p.patient_id, p.patient_name, count(a.appointment_id) as no_of_appointments,
case
when count(a.appointment_id) between 1 and 4 then "Occasional"
when count(a.appointment_id) between 5 and 9 then "Regular"
else "Frequent"
end as patient_category
from patients p
inner join appointments a on p.patient_id = a.patient_id
group by p.patient_id
)
select patient_category, count(*) as no_of_patients,
round(count(*)/(select count(*) from patient_counts)*100,2) as percentage_patient
from patient_counts
group by patient_category
order by no_of_patients desc;




-- which mode of service patients are looking. kind of service people expecting
select count(booking_channel) as no_of_booking_types, booking_channel as orginial_booking
from appointments a group by  booking_channel order by count(booking_channel) desc;

-- which booking channel gave more no of appointments
select count(*) as no_of_appointments, booking_channel
from appointments
group by booking_channel order by no_of_appointments desc;
-- percentage of each bookibg channel

select booking_channel,count(*) as no_of_appointments,
round((count(*) / (select count(*) from appointments))*100,2) as booking_percentage from appointments
group by booking_channel;
-- Which cities have the most active patients, measured by average appointments per patient?
select p.city, count(*) as total_appointments,
count(distinct p.patient_id) as no_of_patients,
round(count(*)/count(distinct p.patient_id),2) as appts_per_patient,
dense_rank() over(order by count(*) desc) as volume_ranks,
dense_rank() over(order by count(*)/count(distinct p.patient_id) desc) as activity_rank
from patients p inner join 
appointments a on p.patient_id = a.patient_id
group by city
order by activity_rank;








--  different kind of patient names by type of treatment:

select *  from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id;

select p.patient_name from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id;

-- Treatment table
-- total records 3500
select count(*) from treatments;

-- select all the data :
select * from treatments;
describe treatments;

select status,count(*) as no_of_treatments  from treatments group by status;

-- getting patient details and their status:
select distinct p.patient_id,p.patient_name,t.status
from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id;
-- show only people complted their treatment
select p.patient_name,t.status
from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id where t.status='Completed';

-- count no of people complted their treatemnt:

select count(*)
from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id where t.status='Completed';

-- count treatment attempts:
select treatment_attempt,count(*) from treatments group by treatment_attempt;
-- list of patients with no of treatment attempts
select distinct p.patient_id, p.patient_name,t.status, t.treatment_attempt
from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id;

-- treatment duration
select min(treatment_duration_min), max(treatment_duration_min), avg(treatment_duration_min) 
from treatments;
-- waiting time: 
select min(waiting_time_min), max(waiting_time_min), round(avg(waiting_time_min),2)
from treatments;

select min(actual_treatment_date), max(actual_treatment_date) from treatments;

-- traetments completed , cancelled in cities:
select p.city,t.status,count(*) as no_of_treatemnts
from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id
group by p.city,t.status
order by no_of_treatemnts desc;
-- 
select p.city,count(*) as no_of_treatemnts,
sum(
case when t.status='Completed' then 1 else 0 end) as completed,
sum(
case when t.status='Rescheduled' then 1 else 0 end) as rescheduled,
sum(
case when t.status='No-Show' then 1 else 0 end) as noshow,
sum(
case when t.status='Cancelled' then 1 else 0 end) as cancelled,
round(sum(case when t.status='Completed' then 1 else 0 end)/ count(*) * 100,2) as completed_rate,
round(sum(case when t.status in ('Cancelled','No-Show','Rescheduled') then 1 else 0 end) /count(*) * 100, 2) as problem_rate

from patients p inner join appointments a on p.patient_id = a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id
group by p.city
order by completed_rate desc;

 
 
 -- 
 -- How do treatment outcomes and completion rates compare across service types?
select t.status,a.service_type
from appointments a 
inner join treatments t on a.appointment_id = t.appointment_id
;
-- now count them along with status and service_type:
select t.status,a.service_type,count(*) as no_of_treatemnts
from appointments a 
inner join treatments t on a.appointment_id = t.appointment_id
group by t.status,a.service_type order by no_of_treatemnts desc;

-- now adding completed column:
select a.service_type,count(*) as no_of_treatemnts,
sum(case when t.status='Completed' then 1 else 0 end) as completed,
sum(case when t.status = 'Cancelled' then 1 else 0 end) as cancelled,
sum(case when t.status ='Rescheduled' then 1 else 0 end ) as rescheduled,
sum(case when t.status = 'No-Show' then 1 else 0 end ) as noshow,
round(
sum(case when t.status='Completed' then 1 else 0 end)/count(*) * 100,2) as completed_rate,
round(
sum(case when t.status in('Cancelled','Rescheduled','No-Show') then 1 else 0 end)/count(*) * 100,2) as problem_rate
from appointments a 
inner join treatments t on a.appointment_id = t.appointment_id
group by a.service_type order by completed_rate desc;

-- Q: Which service types have the longest average treatment duration and waiting time?
select a.service_type,round(avg(t.treatment_duration_min), 2) as avg_duration,
round(avg(t.waiting_time_min), 2) as avg_waiting_time

from appointments a 
inner join treatments t on a.appointment_id = t.appointment_id
group by a.service_type
;

select status, round(avg(treatment_duration_min), 2) as avg_duration
from treatments where status='Completed'
group by status ;

-- each month no of treatments: 
   select month(actual_treatment_date) as month_no,
          monthname(actual_treatment_date) as month_name,
          count(*) as no_of_treatments
   from treatments
   group by month(actual_treatment_date), monthname(actual_treatment_date)
   order by month_no;
   
-- entire doctors table:
select * from doctors;
-- no of doctors:
select count(*) as no_of_doctors from doctors;

-- speciality with count of doctors:
select speciality, count(*) as no_of_doctors from doctors
group by speciality order by no_of_doctors desc;

-- list of active doctors:
select speciality,is_active,count(*) as no_of_doctors from doctors
group by is_active,speciality order by is_active desc;

-- list of doctors with employment type
select speciality,count(*) as no_of_doctors,employment_type
from doctors group by employment_type,speciality;

-- rating:
select rating,doctor_name from doctors where rating between 4 and 5;

select rating,count(*) from doctors where rating between 4 and 5
group by rating;

select min(rating) as min_rating, max(rating) as max_rating, round(avg(rating), 2) as avg_rating from doctors;

-- setting a bands for rating:
select doctor_name, rating,
case
when rating >4.5 then "Excellent"
when rating between 4.0 and 4.49 then "Good"
when rating < 4.0 then "Needs Improvment"
end as band
from doctors;
-- 
select min(hire_date), max(hire_date) from doctors;

-- 
select year(hire_date),count(*) as no_of_doctors from doctors
group by year(hire_date) order by no_of_doctors desc;

-- Which doctors handle the most treatments?
select d.doctor_id,d.doctor_name,count(t.treatment_id) as no_of_treatments
from doctors d left join  treatments t  on d.doctor_id = t.doctor_id
group by d.doctor_id order by no_of_treatments desc;

-- how many doctor rows, and how many unique IDs?
select count(*) as total_rows,
       count(distinct doctor_id) as unique_doctors
from doctors;
-- Which doctors have the highest completion rates?
select d.doctor_id,d.doctor_name,d.rating, count(*) as no_of_treatments,
sum(case
when t.status = 'Completed' then 1 else 0 end) as completed,
round(
sum(case
when t.status = 'Completed' then 1 else 0 end)/ count(*) *100,2) as completed_rate
from doctors d left join  treatments t  on d.doctor_id = t.doctor_id
group by d.doctor_id,d.doctor_name,d.rating order by completed_rate desc limit 5;

-- lowest:
select d.doctor_id,d.doctor_name,d.rating, count(*) as no_of_treatments,
sum(case
when t.status = 'Completed' then 1 else 0 end) as completed,
round(
sum(case
when t.status = 'Completed' then 1 else 0 end)/ count(*) *100,2) as completed_rate,

from doctors d left join  treatments t  on d.doctor_id = t.doctor_id
group by d.doctor_id,d.doctor_name,d.rating order by completed_rate  limit 5;

--
with rates as(
select d.doctor_id,d.doctor_name,d.rating, count(*) as no_of_treatments,
sum(case
when t.status = 'Completed' then 1 else 0 end) as completed,
round(
sum(case
when t.status = 'Completed' then 1 else 0 end)/ count(*) *100,2) as completed_rate
from doctors d left join  treatments t  on d.doctor_id = t.doctor_id
group by d.doctor_id,d.doctor_name,d.rating order by completed_rate 
)
select *,
dense_rank() over(order by completed_rate desc) as best_rank,
dense_rank() over(order by completed_rate) as worst_rank
from rates
order by completed_rate desc;

-- Which doctors have the longest average treatment duration?
select d.doctor_id,d.doctor_name, count(t.treatment_id) as no_of_treatments,
max(t.treatment_duration_min) as longest_duration, 
round(avg(t.treatment_duration_min),2) as avg_duration,t.status 
from doctors d inner join treatments t on
d.doctor_id = t.doctor_id where t.status='Completed'
group by d.doctor_id,d.doctor_name order by avg_duration desc;


-- treatemnt cost for the speciality along with doctor name
select d.doctor_name,d.speciality, t.status,
min(t.treatment_cost) as min_treatment_cost,max(t.treatment_cost) as max_treatment_cost,
round(avg(t.treatment_cost),2) as avg_treatment_cost
from doctors d inner join treatments t on
d.doctor_id = t.doctor_id where t.status='Completed'
group by d.doctor_id,d.speciality; 

-- even for cancellation cost is added.
select status, min(treatment_cost), round(avg(treatment_cost), 2)
from treatments group by status;
-- Which specialties have the highest average treatment cost (completed treatments only)?
select d.speciality,count(*) as no_of_treatments,
min(t.treatment_cost) as min_treatment_cost, 
round(avg(t.treatment_cost), 2) as avg_treatment_cost
from doctors d inner join treatments t on d.doctor_id = t.doctor_id
where t.status='Completed'
group by d.speciality
order by avg_treatment_cost desc;

-- treatemnt cost for the speciality along with doctor name with patient name and appointment_date as well.
select p.patient_id,p.patient_name,d.doctor_name,d.speciality,
count(*) as no_of_treatments,
min(a.appointment_date) as first_visit,
max(a.appointment_date) as last_visit,
sum(
case when t.status='Completed' then 1 else 0 end) as completed,
sum(case when t.status in ('Cancelled','No-Show','Reschedules')then 1 else 0 end) as problem_treatments,
sum(case when t.status = 'Completed' then t.treatment_cost else 0 end) as completed_cost,
 sum(t.treatment_cost) as treatment_cost_per_patient
from doctors d inner join treatments t on
d.doctor_id = t.doctor_id inner join appointments a on t.appointment_id = a.appointment_id
inner join patients p on a.patient_id = p.patient_id
group by d.doctor_id,d.speciality,p.patient_id,a.appointment_date
order by no_of_treatments desc limit 10; 


-- rooms table:
select * from rooms;
-- total no of rooms
select count(*) from rooms;
-- count of room types
select room_type, count(*) as no_of_rooms from rooms group by room_type;
-- Total number of floors:
select floor from rooms group by floor;
-- differnt types of equipment_type:
select equipment_type from rooms group by equipment_type;
select equipment_type,count(*) as no_of_rooms from rooms group by equipment_type;
-- capacity
select capacity from rooms;

select capacity,count(*) as room_capacity from rooms group by capacity;

-- last maintenance_date
select min(last_maintenance_date) as first_service_date, max(last_maintenance_date) as last_service_date 
from rooms;
-- is_avaiable
select is_available, count(*) as no_of_rooms from rooms group by is_available; 


-- Which room types are used most for treatments, and how many treatments does each room handle on average?

select r.room_type,count(t.treatment_id) as no_of_treatments,
count(distinct r.room_id) as no_of_rooms,
round(count(t.treatment_id) /count(distinct r.room_id) ,2) as treatments_per_room
from treatments t inner join rooms r on t.room_id = r.room_id
group by r.room_type
order by treatments_per_room desc;

-- Which room types have the best and worst treatment completion rates?
select r.room_type,count(t.treatment_id) as no_of_treatments,
count(distinct r.room_id) as no_of_rooms,
round(count(t.treatment_id) /count(distinct r.room_id) ,2) as treatments_per_room,
sum(case when t.status='Completed' then 1 else 0 end) as completed,
sum(case when t.status in('Cancelled','No-Show','Rescheduled') then 1 else 0 end) as problem_treatments,
round(sum(case when t.status='Completed' then 1 else 0 end)/count(t.treatment_id) * 100,2) as completed_rate
from treatments t inner join rooms r on t.room_id = r.room_id
group by r.room_type
order by completed_rate desc;

select r.equipment_type,count(t.treatment_id) as no_of_treatments,
count(distinct r.room_id) as no_of_rooms,
round(count(t.treatment_id) /count(distinct r.room_id) ,2) as treatments_per_room,
sum(case when t.status='Completed' then 1 else 0 end) as completed,
sum(case when t.status in('Cancelled','No-Show','Rescheduled') then 1 else 0 end) as problem_treatments,
round(sum(case when t.status='Completed' then 1 else 0 end)/count(t.treatment_id) * 100,2) as completed_rate
from treatments t inner join rooms r on t.room_id = r.room_id
group by r.equipment_type
order by completed_rate desc;



-- Are different room types used for different service types?

select r.room_type,a.service_type,count(t.treatment_id) as no_of_treatments
from treatments t inner join rooms r on t.room_id = r.room_id
inner join appointments a on t.appointment_id = a.appointment_id
group by r.room_type,a.service_type
order by r.room_type,no_of_treatments desc;


-- -- 4.4 Q: Are different room and equipment types used for different service types?

select r.room_type,a.service_type,r.equipment_type,count(t.treatment_id) as no_of_treatments
from treatments t inner join rooms r on t.room_id = r.room_id
inner join appointments a on t.appointment_id = a.appointment_id
group by r.room_type,a.service_type,r.equipment_type
order by r.room_type,no_of_treatments desc;

-- 4.5 Q: Which appointments needed more than one treatment attempt?
select appointment_id, count(*) as no_of_attempts
from treatments
group by appointment_id
having count(*) > 1;
-- now adding service_type
select t.appointment_id,a.service_type, count(*) as no_of_attempts
from treatments t inner join  appointments a on t.appointment_id=a.appointment_id
group by appointment_id
having count(*) > 1;
-- Do multiple-attempt appointments have longer waiting times?
select t.appointment_id,a.service_type, count(*) as no_of_attempts,max(t.waiting_time_min) as max_waiting_time
from treatments t inner join  appointments a on t.appointment_id=a.appointment_id
group by appointment_id
having count(*) > 1
order by max_waiting_time desc;

-- Which cities and service types have the most cancellations, no-shows, and rescheduling?
select
p.city, a.service_type,count(*) as no_of_treatments,
  sum(case when t.status = 'Cancelled'   then 1 else 0 end) as cancelled,
  sum(case when t.status = 'No-Show'     then 1 else 0 end) as no_show,
  sum(case when t.status = 'Rescheduled' then 1 else 0 end) as rescheduled,
round(sum(case when t.status in ('Cancelled','No-Show','Rescheduled') then 1 else 0 end)/count(*) * 100,2) as problem_rate
from patients p inner join appointments a on p.patient_id=a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id
group by p.city,a.service_type
order by problem_rate desc;


select count(*) as no_of_treatments,a.priority,round(avg(t.waiting_time_min),2) as avg_waiting_time,
round(sum(case when t.status = 'Completed' then 1 else 0 end) / count(*) * 100, 2) as completion_rate,
round(sum(case when t.status in ('Cancelled','No-Show','Rescheduled') 
then 1 else 0 end) / count(*) * 100, 2) as problem_rate
  from patients p inner join appointments a on p.patient_id=a.patient_id
inner join treatments t on a.appointment_id = t.appointment_id
group by a.priority
order by avg_waiting_time desc;


select  a.patient_id,count(distinct a.appointment_id) as no_of_appointments,
count(t.treatment_attempt) as no_of_treatemnets_attempt,
round(avg(t.waiting_time_min),2) as avg_waiting_time from appointments a
inner join treatments t on a.appointment_id= t.appointment_id
group by a.patient_id order by avg_waiting_time desc;

-- Do second-attempt treatments involve longer waiting times than first attempts?

select treatment_attempt,count(*) as no_of_treatments,
round(avg(waiting_time_min),2) as avg_waiting_time
 from treatments group by treatment_attempt;
 
select
sum(case when status in ('Cancelled','Reschedules','No-Show') then 1 else 0 end) as problem_status,
round(
sum(case when status in ('Cancelled','Reschedules','No-Show') then 1 else 0 end)/count(*) *100,2 )as problem_rate
from treatments;
-- What are the most common problem statuses, and what share of all treatments does each one affect?
select count(*) as no_of_treatments,
sum(case when status = 'Cancelled' then 1 else 0 end) as cancelled_problem_status,
sum(case when status = 'Rescheduled' then 1 else 0 end) as rescheduled_problem_status,
sum(case when status = 'No-Show' then 1 else 0 end) as noshow_problem_status,
round(
sum(case when status = 'Cancelled' then 1 else 0 end)/count(*) *100,2 )as cancelled_problem_rate,
round(
sum(case when status = 'Rescheduled' then 1 else 0 end)/count(*) *100,2 )as reschedules_problem_rate,
round(
sum(case when status = 'No-Show' then 1 else 0 end)/count(*) *100,2 )as noshow_problem_rate
from treatments;
-- Which service types have the most cancellations, rescheduling, no-shows, and repeat attempts?
-- based on the service type the cancelled, rescheduled, noshow rate
-- based on the query consultation has more no of cancellations, rescheduled and no show up cases.
select count(*) as no_of_treatments,a.service_type,
sum(case when t.status = 'Cancelled' then 1 else 0 end) as cancelled_problem_status,
sum(case when t.status = 'Rescheduled' then 1 else 0 end) as rescheduled_problem_status,
sum(case when t.status = 'No-Show' then 1 else 0 end) as noshow_problem_status,
round(
sum(case when t.status = 'Cancelled' then 1 else 0 end)/count(*) *100,2 )as cancelled_problem_rate,
round(
sum(case when t.status = 'Rescheduled' then 1 else 0 end)/count(*) *100,2 )as reschedules_problem_rate,
round(
sum(case when t.status = 'No-Show' then 1 else 0 end)/count(*) *100,2 )as noshow_problem_rate,
sum(case when t.treatment_attempt =2 then 1 else 0 end) as second_attempts,
round(sum(case when t.treatment_attempt =2 then 1 else 0 end)/count(*) *100,2) as second_attempts_rate

from treatments t
inner join appointments a on t.appointment_id = a.appointment_id
group by a.service_type; 


-- creating a master query:
create view treatment_full_details as 
select
--  treatment
t.treatment_id, t.treatment_attempt,t.status,t.actual_treatment_date,t.treatment_duration_min,
t.waiting_time_min, t.treatment_cost,
-- appointment
a.appointment_id,a.appointment_date,a.service_type,a.estimated_cost,a.booking_channel,a.priority,
-- patient
p.patient_id,p.patient_name,p.city,p.patient_type,p.age,p.preferred_time_slot,p.registration_date,
-- doctors
d.doctor_id,d.doctor_name,d.speciality,d.hire_date,d.rating,d.employment_type,d.is_active,
-- rooms
r.room_id,r.room_type,r.floor,r.equipment_type,r.capacity,
r.last_maintenance_date,r.is_available
from treatments t inner join appointments a on t.appointment_id = a.appointment_id 
inner join patients p on a.patient_id = a.patient_id inner join
doctors d on t.doctor_id = d.doctor_id inner join rooms r on
t.room_id = r.room_id;

select city, round(avg(waiting_time_min), 2) as avg_wait
from treatment_full_details
group by city;

select waiting_time_min, avg(waiting_time_min), min(waiting_time_min), max(waiting_time_min) from treatment_full_details
group by waiting_time_min;