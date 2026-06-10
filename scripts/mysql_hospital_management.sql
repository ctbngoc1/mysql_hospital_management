CREATE DATABASE hospital_management;
USE hospital_management;

-- Enable loading data from local files (on server's side) 
SET GLOBAL local_infile=1; 

-- Creating tables    
CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    doctor_id VARCHAR(10),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE billing (
    bill_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    treatment_id VARCHAR(10),
    bill_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(20),
    payment_status VARCHAR(20)
);

CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(50),
    phone_number VARCHAR(20),
    years_experience INT,
    hospital_branch VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(1),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    address VARCHAR(100),
    registration_date DATE,
    insurance_provider VARCHAR(50),
    insurance_number VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10),
    treatment_type VARCHAR(50),
    description VARCHAR(50),
    cost DECIMAL(10,2),
    treatment_date DATE
);

-- Load data into tables 
LOAD DATA LOCAL INFILE 'C:/Ngoc/SQL/hospital_management_data/appointments.csv'
INTO TABLE appointments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Ngoc/SQL/hospital_management_data/billing.csv'
INTO TABLE billing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Ngoc/SQL/hospital_management_data/doctors.csv'
INTO TABLE doctors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Ngoc/SQL/hospital_management_data/patients.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Ngoc/SQL/hospital_management_data/treatments.csv'
INTO TABLE treatments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Show tables
SELECT * FROM appointments;
SELECT * FROM billing;
SELECT * FROM doctors;
SELECT * FROM patients;
SELECT * FROM treatments;

-- Observation: These tables are already normalized 

-- ### Data Cleaning
-- The dataset appears to be synthetically generated, where treatments and billing records are associated with appointments regardless of appointment status.
-- However, in real-world scenarios, treatments and billing would typically only occur for completed appointments.
-- Therefore, to ensure realistic analysis, treatments and billing records associated with non-completed appointments were removed. 

-- Delete billing records linked to non-completed appointments
DELETE b FROM billing b
INNER JOIN treatments t 
    ON b.treatment_id = t.treatment_id
INNER JOIN appointments a
    ON t.appointment_id = a.appointment_id
WHERE a.status <> 'Completed';

-- Delete treatments linked to non-completed appointments
DELETE t FROM treatments t   
INNER JOIN appointments a
    ON t.appointment_id = a.appointment_id
WHERE a.status <> 'Completed';

-- ### Goal: Build a hospital operations and analytics system that helps management track patients, doctors, appointments, billing, and operational efficiency.

-- A/ Hospital operations simulation
-- New patient admission 
INSERT INTO patients (patient_id, first_name, last_name, gender, date_of_birth, contact_number, address, registration_date, insurance_provider, insurance_number, email)
VALUES ('P051', 'Astrid', 'Bowers', 'F', '2000-12-10', '0123456789', '579 Fae St', '2024-01-10', 'PulseSecure', 'INS987654', 'astrid.bowers@mail.com');

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status)
VALUES ('A201', 'P051', 'D001', '2024-01-20', '09:00:00', 'Consultation', 'Scheduled');

-- 1st appointment cancelled 
UPDATE appointments
SET status = 'Cancelled' WHERE appointment_id = 'A201';

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status)
VALUES ('A202', 'P051', 'D001', '2024-02-01', '09:00:00', 'Consultation', 'Scheduled');

-- After the 1st appointment 
UPDATE appointments
SET status = 'Completed' WHERE appointment_id = 'A202';

INSERT INTO treatments (treatment_id, appointment_id, treatment_type, description, cost, treatment_date)
VALUES ('T201', 'A202', NULL, NULL, NULL, '2024-02-01');   -- Some consultation / follow-up / check-up appointments may not have any treatments. The treatments and billing tables only need to be updated if the appointment status is completed 

INSERT INTO billing (bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status)
VALUES ('B201', 'P051', 'T201', '2024-02-01', 50.00, 'Cash', 'Paid');

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status)
VALUES ('A203', 'P051', 'D001', '2024-02-10', '09:00:00', 'Therapy', 'Scheduled');

-- After the 2st appointment
UPDATE appointments
SET status = 'Completed' WHERE appointment_id = 'A203';

INSERT INTO treatments (treatment_id, appointment_id, treatment_type, description, cost, treatment_date)
VALUES ('T202', 'A203', 'CO2', 'Fractional CO2 laser', 2000.00, '2024-02-10');

INSERT INTO billing (bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status)
VALUES ('B202', 'P051', 'T202', '2024-02-10', 2050.00, 'Credit Card', 'Pending');   -- Bill amount includes the treatment cost (2000) and consultation cost (50) 

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status)
VALUES ('A204', 'P051', 'D001', '2024-02-20', '09:00:00', 'Follow-up', 'Scheduled');

UPDATE billing 
SET payment_status = 'Paid' WHERE bill_id = 'B202';

-- After the last appointment
UPDATE appointments
SET status = 'Completed' WHERE appointment_id = 'A204';

INSERT INTO treatments (treatment_id, appointment_id, treatment_type, description, cost, treatment_date)
VALUES ('T203', 'A204', NULL, NULL, NULL, '2024-02-20');

INSERT INTO billing (bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status)
VALUES ('B203', 'P051', 'T203', '2024-02-20', 150.00, 'Cash', 'Paid');   -- Bill amount includes the medication cost (100) and consultation cost (50) 

-- Update all appointments before today with Scheduled status into No-show 
UPDATE appointments
SET status = 'No-show'
WHERE status = 'Scheduled' AND appointment_date < CURDATE();

-- Update payment status of all pending bills before November 2023 as Failed 
UPDATE billing
SET payment_status = 'Failed'
WHERE payment_status = 'Pending' AND bill_date < '2023-11-01';

-- B/ Hospital performance analysis 

-- 1. KPI 
-- Total number of patients
SELECT COUNT(patient_id) AS total_patients
FROM patients;

-- Total appointments and completed appointments 
SELECT COUNT(*) AS total_appointments, SUM(status = 'Completed') AS completed_appointments 
FROM appointments;

-- Total revenue
SELECT SUM(amount) AS total_revenue
FROM billing
WHERE payment_status = 'Paid';

-- No-show rate 
SELECT COUNT(*) AS total_appointments, SUM(status = 'No-show') AS no_show_count,
    SUM(status = 'No-show') * 1.0 / COUNT(*) AS no_show_rate
FROM appointments;

-- 2. Distribution analysis 
-- Appointment status distribution
SELECT status, COUNT(*) AS total_appointments 
FROM appointments
GROUP BY status;
-- (The number of no-show appointments is high because all past appointments with a Scheduled status were updated to No-show)

-- Treatment usage
SELECT treatment_type, COUNT(*) AS usage_count
FROM treatments
WHERE treatment_type IS NOT NULL
GROUP BY treatment_type;

-- Revenue by payment method
SELECT payment_method, SUM(amount) AS total_amount, 
	RANK() OVER (ORDER BY SUM(amount) DESC) AS amount_rank 
FROM billing
WHERE payment_status = 'Paid' 
GROUP BY payment_method;

-- 3. Monthly performance 
-- Monthly revenue and cumulative revenue, with revenue category added 
WITH paid_amount_calc AS (
	SELECT DATE_FORMAT(b.bill_date, '%Y-%m') AS month,   -- Convert date to YYYY-MM 
        SUM(CASE 
				WHEN b.payment_status = 'Paid' THEN b.amount 
                ELSE 0 
			END) AS monthly_revenue
    FROM appointments a
    INNER JOIN treatments t   -- Automatically removes non-completed appointments
        ON a.appointment_id = t.appointment_id
    INNER JOIN billing b
        ON t.treatment_id = b.treatment_id
    GROUP BY DATE_FORMAT(b.bill_date, '%Y-%m')
)
SELECT month, monthly_revenue,
    CASE 
        WHEN monthly_revenue > 5000 THEN 'High Revenue'
        WHEN monthly_revenue > 2000 THEN 'Medium Revenue'
        WHEN monthly_revenue > 0 THEN 'Low Revenue'
        ELSE 'No Revenue'
    END AS revenue_category,
    SUM(monthly_revenue) OVER (ORDER BY month) AS cumulative_revenue   -- Use running total 
FROM paid_amount_calc
ORDER BY month;   -- Using WHERE b.payment_status = 'Paid' would not have counted unpaid appointments and show unpaid bill dates 

-- Average revenue per appointment (= Total revenue / number of unique appointments) and Total appointments by month
WITH revenue_data AS (
    SELECT a.appointment_id, DATE_FORMAT(b.bill_date, '%Y-%m') AS month,
        CASE 
            WHEN b.payment_status = 'Paid' THEN b.amount 
            ELSE 0 
        END AS paid_amount
    FROM appointments a
    INNER JOIN treatments t  
        ON a.appointment_id = t.appointment_id
    INNER JOIN billing b  
        ON t.treatment_id = b.treatment_id
)
SELECT 
    month,
    COUNT(DISTINCT appointment_id) AS total_appointments,
    SUM(paid_amount) / COUNT(DISTINCT appointment_id) AS revenue_per_appointment
FROM revenue_data
GROUP BY month
ORDER BY month;

-- 4. Specialization demand analysis
-- Number of doctors and appointments for each specialization, ranked from most to least popular specialization
SELECT d.specialization, 
	COUNT(DISTINCT a.appointment_id) AS total_appointments, COUNT(DISTINCT d.doctor_id) AS total_doctors,
    RANK() OVER (ORDER BY COUNT(DISTINCT a.appointment_id) DESC) AS demand_rank
FROM doctors d 
LEFT JOIN appointments a 
    ON d.doctor_id = a.doctor_id
GROUP BY d.specialization;

-- 5. Doctor workload analysis 
-- Number of appointments per doctor, ranked from most to least popular doctor 
SELECT d.doctor_id, d.first_name, d.last_name, d.specialization,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    RANK() OVER (ORDER BY COUNT(DISTINCT a.appointment_id) DESC) AS workload_rank
FROM doctors d
LEFT JOIN appointments a 
    ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;

-- 6. Patient retention rate 
-- Percentage of patients who come back after their first visit
WITH patient_visits AS (
	SELECT p.patient_id, COUNT(DISTINCT a.appointment_id) AS total_visits   -- Only counts patients that have completed at least 1 appointment
    FROM patients p
    INNER JOIN appointments a
        ON p.patient_id = a.patient_id
    WHERE a.status = 'Completed'
    GROUP BY p.patient_id
),
joined_data AS (
    SELECT patient_id, total_visits,
        CASE 
			WHEN total_visits > 1 THEN 1 
			ELSE 0
		END AS is_returning
    FROM patient_visits
)
SELECT COUNT(DISTINCT patient_id) AS total_patients, SUM(is_returning) AS returning_patients,
    SUM(is_returning) * 1.0 / COUNT(DISTINCT patient_id) AS retention_rate
FROM joined_data;

-- 7. Patients rankings 
-- Revenue of each patient, ranked, with segment added 
WITH patient_revenue AS (
    SELECT p.patient_id, p.first_name, p.last_name,
	COALESCE(SUM(CASE 
					WHEN b.payment_status = 'Paid' THEN b.amount    -- COALESCE returns the first value that isn't NULL in a list 
                    ELSE 0 
				END), 0) AS total_paid
    FROM patients p
    LEFT JOIN appointments a 
        ON p.patient_id = a.patient_id
    LEFT JOIN treatments t 
        ON a.appointment_id = t.appointment_id
    LEFT JOIN billing b 
        ON t.treatment_id = b.treatment_id
    GROUP BY p.patient_id
)
SELECT *,
    CASE
        WHEN total_paid > 3000 THEN 'VIP'
        WHEN total_paid > 2000 THEN 'High Value'
        WHEN total_paid > 0 THEN 'Regular'
        ELSE 'No Revenue'
    END AS segment,
    DENSE_RANK() OVER (ORDER BY total_paid DESC) AS revenue_rank
FROM patient_revenue;

-- Number of visits per patient, counting only completed appointments, ranked from most to least visits 
WITH patient_visits AS (
	SELECT p.patient_id, p.first_name, p.last_name,
		COALESCE(SUM(CASE
				WHEN a.status = 'Completed' THEN 1 
                ELSE 0
			END), 0) AS total_visits
	FROM patients p 
    LEFT JOIN appointments a
    ON a.patient_id = p.patient_id
	GROUP BY p.patient_id
)
SELECT *,
    DENSE_RANK() OVER (ORDER BY total_visits DESC) AS num_visit_rank   -- Used DENSE_RANK() instead of RANK() to avoid gaps in ranking when multiple patients have the same number of visits, ensuring a continuous ranking
FROM patient_visits;

-- 8. Other analyses 
-- Patient hospital visits tracking
SELECT p.patient_id, p.first_name, p.last_name, a.appointment_date, a.status,
	ROW_NUMBER() OVER (
		PARTITION BY p.patient_id 
        ORDER BY a.appointment_date
        ) AS visit_order   
FROM patients p 
INNER JOIN appointments a
ON a.patient_id = p.patient_id; 

-- Check hospital history of a specific patient 
SELECT 
	ROW_NUMBER() OVER (
        PARTITION BY a.patient_id 
        ORDER BY a.appointment_date
    ) AS visit_order,
    a.appointment_date, a.appointment_time, CONCAT(first_name, ' ', last_name) AS doctor_name, a.reason_for_visit, a.status,   -- Merge the doctor's first and last name 
    t.treatment_type, t.description, t.cost AS treatment_cost, 
    b.bill_date, b.amount AS billing_amount, b.payment_method, b.payment_status
FROM appointments a
LEFT JOIN doctors d
	ON a.doctor_id = d.doctor_id 
LEFT JOIN treatments t 
    ON a.appointment_id = t.appointment_id
LEFT JOIN billing b 
    ON t.treatment_id = b.treatment_id 
WHERE a.patient_id = 'P051'
ORDER BY a.appointment_date;

-- Check patients that have cancelled or not show up to an appointment at least twice, ranked from most to least missed appointments 
WITH missed_counts AS (
    SELECT p.patient_id, p.first_name, p.last_name, 
		SUM(a.status = 'Cancelled') AS cancelled_count,
		SUM(a.status = 'No-show') AS no_show_count,
		COUNT(*) AS missed_appointments
    FROM patients p 
    INNER JOIN appointments a
    ON a.patient_id = p.patient_id
    WHERE a.status IN ('Cancelled', 'No-show')
    GROUP BY patient_id
    HAVING COUNT(*) >= 2
)
SELECT *,
    DENSE_RANK() OVER (ORDER BY missed_appointments DESC) AS missed_rank
FROM missed_counts;

-- Check patients that have completed at least 2 appointments and paid over 2000$ in total 
WITH joined_data AS (
    SELECT a.patient_id, p.first_name, p.last_name, SUM(a.status = 'Completed') AS completed_appointments,
		SUM(CASE
				WHEN b.payment_status = 'Paid' THEN b.amount
                ELSE 0
			END) AS total_paid
    FROM appointments a
    INNER JOIN patients p
		ON a.patient_id = p. patient_id 
    INNER JOIN treatments t 
		ON a.appointment_id = t.appointment_id
    INNER JOIN billing b 
        ON t.treatment_id = b.treatment_id
    GROUP BY a.patient_id
)
SELECT *
FROM joined_data
WHERE completed_appointments >= 2 AND total_paid > 2000;

-- C/ Views for dashboarding 

-- KPI view (For Total Patients, Total Appointments, Total Revenue and No-show rate cards)  
CREATE VIEW kpi_view AS
SELECT COUNT(DISTINCT p.patient_id) AS total_patients,   -- When using JOINs, each ID can be included in multiple rows and therefore we need to use DISTINCT to count them  
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    SUM(CASE 
			WHEN b.payment_status = 'Paid' THEN b.amount 
			ELSE 0 
        END) AS total_revenue,
    SUM(a.status = 'No-show') * 1.0 / COUNT(DISTINCT a.appointment_id) AS no_show_rate
FROM patients p
LEFT JOIN appointments a 
    ON p.patient_id = a.patient_id
LEFT JOIN treatments t 
    ON a.appointment_id = t.appointment_id
LEFT JOIN billing b 
    ON t.treatment_id = b.treatment_id;   
    
SELECT * FROM kpi_view; 

-- Appointment status view (For donut chart of Appointment Status Distribution)
CREATE VIEW appointment_status_view AS
SELECT status, COUNT(*) AS total_appointments 
FROM appointments
GROUP BY status;

SELECT * FROM appointment_status_view;

-- Treatment usage view (For bar chart of Treatment Usage by Type)
CREATE VIEW treatment_usage_view AS 
SELECT treatment_type, COUNT(*) AS usage_count
FROM treatments
WHERE treatment_type IS NOT NULL
GROUP BY treatment_type;

SELECT * FROM treatment_usage_view;

-- Revenue by payment method view (For donut chart of Revenue Distribution by Payment Method)
CREATE VIEW payment_method_view AS 
SELECT payment_method, SUM(amount) AS total_amount, 
	RANK() OVER (ORDER BY SUM(amount) DESC) AS amount_rank 
FROM billing
WHERE payment_status = 'Paid' 
GROUP BY payment_method;

SELECT * FROM payment_method_view;

-- Monthly performance view (For a line chart of Monthly Revenue, a line chart of Cumulative Revenue over Time, and a bar chart of Revenue per Appointment by Month)
CREATE VIEW monthly_perf_view AS
WITH paid_amount_calc AS (
    SELECT DATE_FORMAT(b.bill_date, '%Y-%m') AS month,   -- Use '%Y-%m' instead of '%m-%Y' for correct chronological sorting
        COUNT(DISTINCT a.appointment_id) AS total_appointments,
        SUM(CASE 
                WHEN b.payment_status = 'Paid' THEN b.amount 
                ELSE 0 
            END) AS monthly_revenue
    FROM appointments a
    INNER JOIN treatments t   
        ON a.appointment_id = t.appointment_id
    INNER JOIN billing b
        ON t.treatment_id = b.treatment_id
    GROUP BY DATE_FORMAT(b.bill_date, '%Y-%m')
)
SELECT month, monthly_revenue, total_appointments,
    monthly_revenue / total_appointments AS revenue_per_appointment,
    SUM(monthly_revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM paid_amount_calc
ORDER BY month;   

SELECT * FROM monthly_perf_view; 

-- Specialization demand view (For a bar chart of Total Appointments by Specialization, a stacked bar to compare Total Doctors and Total Appointments)
CREATE VIEW specialization_demand_view AS
SELECT d.specialization, 
	COUNT(DISTINCT a.appointment_id) AS total_appointments, COUNT(DISTINCT d.doctor_id) AS total_doctors,
    RANK() OVER (ORDER BY COUNT(DISTINCT a.appointment_id) DESC) AS demand_rank
FROM doctors d 
LEFT JOIN appointments a 
    ON d.doctor_id = a.doctor_id
GROUP BY d.specialization;

SELECT * FROM specialization_demand_view; 

-- Doctor workload view (For a bar chart of Top 5 busiest doctors with Specialization as the legend, a leaderboard table of Doctors by Total Appointments)
CREATE VIEW doctor_workload_view AS
SELECT d.doctor_id, d.first_name, d.last_name, d.specialization,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    RANK() OVER (ORDER BY COUNT(DISTINCT a.appointment_id) DESC) AS workload_rank
FROM doctors d
LEFT JOIN appointments a 
    ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;

SELECT * FROM doctor_workload_view; 

-- Patient retention view (For a donut chart of Returning vs Non-returning patients)
CREATE VIEW patient_retention_view AS
WITH patient_visits AS (
	SELECT p.patient_id, COUNT(DISTINCT a.appointment_id) AS total_visits   
    FROM patients p
    INNER JOIN appointments a
        ON p.patient_id = a.patient_id
    WHERE a.status = 'Completed'
    GROUP BY p.patient_id
),
joined_data AS (
    SELECT patient_id, total_visits,
        CASE 
			WHEN total_visits > 1 THEN 1 
			ELSE 0
		END AS is_returning
    FROM patient_visits
)
SELECT COUNT(DISTINCT patient_id) AS total_patients, SUM(is_returning) AS returning_patients,
    SUM(is_returning) * 1.0 / COUNT(DISTINCT patient_id) AS retention_rate
FROM joined_data;

SELECT * FROM patient_retention_view;

-- Patient segmentation view (For a pie chart of Segment (VIP, High Value, ...) distribution, a bar chart of Total Revenue by Segment, and a leaderboard table to rank Patients by Revenue)
CREATE VIEW patient_segmentation_view AS
WITH patient_revenue AS (
    SELECT p.patient_id, p.first_name, p.last_name,
	COALESCE(SUM(CASE 
					WHEN b.payment_status = 'Paid' THEN b.amount 
                    ELSE 0 
				END), 0) AS total_paid
    FROM patients p
    LEFT JOIN appointments a 
        ON p.patient_id = a.patient_id
    LEFT JOIN treatments t 
        ON a.appointment_id = t.appointment_id
    LEFT JOIN billing b 
        ON t.treatment_id = b.treatment_id
    GROUP BY p.patient_id
)
SELECT *,
    CASE
        WHEN total_paid > 3000 THEN 'VIP'
        WHEN total_paid > 2000 THEN 'High Value'
        WHEN total_paid > 0 THEN 'Regular'
        ELSE 'No Revenue'
    END AS segment,
    DENSE_RANK() OVER (ORDER BY total_paid DESC) AS revenue_rank
FROM patient_revenue;

SELECT * FROM patient_segmentation_view;
