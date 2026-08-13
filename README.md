# Hospital Management Data Analysis Using MySQL

## Overview

This project demonstrates operational simulation and performance analysis of a relational hospital management database using MySQL. It simulates everyday hospital operations and uses SQL queries to analyze hospital performance, doctor workload, patient behavior, and revenue trends. The database and analyses were developed and executed using MySQL Workbench.

## Data

This project uses the Hospital Management Dataset, which contains synthetic data describing patients, doctors, appointments, treatments, and billing records. The dataset is publicly available at: <https://www.kaggle.com/datasets/kanakbaghel/hospital-management-dataset>

The dataset consists of 5 relational tables:

- *patients*: List of patients, including personal information, insurance details, registration dates, and contact information.

- *doctors*: List of doctors, including medical specialization, years of experience, hospital branches, and contact information.

- *appointments*: Appointment records, including scheduled date and time, assigned doctors, visit reasons, and appointment status.

- *treatments*: Treatment records, including treatment types, treatment dates, and treatment costs.

- *billing*: Billing record, including billing amounts, billing dates, payment methods, and payment status.

The database contains 50 patients, 10 doctors, and 200 records each for appointments, treatments, and billing. In this synthetic dataset, treatment and billing records were generated regardless of appointment status. However, in real-world scenarios, treatments and billing would typically only exist for completed appointments. Therefore, to ensure a realistic database, treatment and billing records associated with non-completed appointments were removed, leaving 46 treatment records and 46 billing records.

## Methods

Following data preparation, SQL statements were developed to simulate common hospital management operations. These operations included patient registration, appointment scheduling, appointment completion or cancellation, treatment documentation, billing generation, and payment updates. Additional SQL statements were used to automatically mark overdue scheduled appointments as *No-show* and overdue unpaid bills as *Failed*. The simulation resulted in a final database containing 51 patients, 204 booked appointments, and 49 records each for treatments and billing.

The database was then analyzed using SQL queries to evaluate hospital performance. The analyses included hospital KPIs, appointment status distribution, treatment usage, revenue analysis, specialization demand, doctor workload, and patient retention. Reporting queries were also used to segment patients based on revenue, retrieve patient visit histories and frequencies, identify patients with repeated missed appointments, and identify high-value returning patients. Finally, these queries were organized into SQL views to provide reusable data sources for reporting and future dashboard development.

## Results

The final hospital database contained 51 patients and 204 booked appointments, of which 49 were completed, generating a total paid revenue of \$33,313.27. Among all booked appointments, 103 (50.5%) were classified as no-shows and 52 were cancelled, indicating that only a small proportion of scheduled appointments resulted in completed visits. Credit card payments generated the highest revenue (\$13,636.02), followed closely by insurance payments (\$13,327.30), while cash payments contributed the smallest share (\$6349.95). Physiotherapy, chemotherapy, and ECG were the most frequently recorded treatment types.

Revenue analysis showed that monthly revenue fluctuated considerably throughout the January 2023 - February 2024 period. March 2023 generated the highest monthly revenue (\$5093.41), whereas November 2023 recorded no revenue despite having completed appointments due to unpaid bills. No completed appointments were recorded in October 2023 or January 2024, so these months were absent from the monthly revenue analysis. Cumulative revenue increased steadily over time, reaching \$33,313.27 by February 2024. Average revenue per completed appointment also varied substantially between months, with September 2023 recording the highest value (\$2093.18).

Specialization demand analysis revealed that Pediatrics received the highest number of booked appointments (98 across 5 doctors), followed by Dermatology (74 across 3 doctors) and Oncology (32 across 2 doctors). Doctor workload was unevenly distributed, with 2 dermatologists tied for the highest number of booked appointments (29 each), despite Pediatrics having the greatest overall demand. These findings may help inform staffing and resource allocation decisions.

Patient retention analysis indicated that 38.2% of patients returned after their first completed appointment, suggesting that most patients didn't return for a subsequent visit. Furthermore, patient revenue segmentation showed that a substantial proportion of patients generated no revenue, reflecting the effects of missed appointments and unpaid bills.
