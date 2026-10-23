<img width="868" height="657" alt="image" src="https://github.com/user-attachments/assets/9a38ac5d-d02f-4e77-a5c2-1f936c49ce79" /># 🏥 Hospital Patient Care Operations Analytics (MySQL)

A SQL business-analytics project that analyses patient demand, appointment behaviour, treatment performance, doctor and room utilisation, and operational problems for **CarePlus Hospital**, a fictional multi-specialty healthcare provider.

> **Note:** All data is synthetic and was created for learning SQL and relational analysis. It does not represent any real hospital or patient.

---

## 📌 Business Problem

The Hospital Operations team wants to use data to understand:

- Patient demand and appointment behaviour
- Treatment outcomes, duration and waiting time
- Doctor and room performance
- Where and why treatments get cancelled, rescheduled or missed

As the Data Analyst, I built the relational database in MySQL, imported and verified the data, formulated analytical questions, wrote SQL queries, and turned the results into business insights and recommendations.

---

## 🗂️ Dataset

| Table | Rows | Description |
|---|---|---|
| `patients` | 400 | Patient demographics, city, patient type, preferred time slot |
| `appointments` | 3,000 | Booking date, service type, priority, estimated cost, booking channel |
| `treatments` | 3,500 | Treatment status, attempt number, duration, waiting time, cost |
| `doctors` | 80 | Speciality, rating, hire date, employment type, active status |
| `rooms` | 50 | Room type, equipment type, floor, capacity, availability |

**Relationships:** patients → appointments → treatments, doctors → appointments and treatments, rooms → treatments

## 🛠️ Tools & SQL Techniques

**Tools:** MySQL, MySQL Workbench

**Techniques used:**
- Database design with primary keys, foreign keys, constraints and data types
- Multi-table `INNER JOIN` and `LEFT JOIN` (up to 5 tables)
- Aggregations: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT(DISTINCT)`
- Conditional aggregation with `SUM(CASE WHEN ...)` for status breakdowns and rates
- Common Table Expressions (`WITH`)
- Window functions: `DENSE_RANK() OVER (...)`, `SUM(COUNT(*)) OVER ()`
- Subqueries for percentage-of-total calculations
- `GROUP BY` / `HAVING`
- Date functions: `MONTH`, `MONTHNAME`, `YEAR`, `DATE_FORMAT`
- A reusable master `VIEW` joining all five tables

---

## 📁 Project Structure

```
├── README.md
├── images/
│   └── er_diagram.png
└── sql/
    └── (SQL scripts: schema, data verification, Sprint 3 and Sprint 4 analysis)
```

---

## 🔍 Analysis Approach

| Section | Focus |
|---|---|
| **Sprint 1** | Business understanding and ER diagram interpretation |
| **Sprint 2** | Database creation, CSV import and data verification |
| **Sprint 3** | Basic exploration: totals, distinct values, averages |
| **4.1** | Patient and appointment demand (city, service type, priority, month, booking channel) |
| **4.2** | Patient behaviour (frequency bands, top patients, city activity, patient types over time) |
| **4.3** | Treatment performance (outcomes by city and service type, duration, waiting time) |
| **4.4** | Doctor and room performance (workload, completion rates, ratings, room usage) |
| **4.5** | Problems (cancellations, no-shows, rescheduling, repeat attempts, priority vs waiting time) |

Each analysis query is documented with the business question it answers and the insight from its result.

---

## 📊 Key Findings

1. **One in four treatments is disrupted.** 25.71% of treatments were cancelled, rescheduled or no-shows. Rescheduling is the most common problem (10.46%), ahead of cancellations (8.09%) and no-shows (7.17%), which points to scheduling capacity rather than patient behaviour.

2. **Priority does not speed up care.** Urgent patients waited 15.97 minutes on average, slightly longer than Routine (15.62) and High (15.47) priority patients. Completion rates were almost identical (about 70%) across all priorities.

3. **The busiest city has the lowest completion rate.** Kochi handled the most treatments (520) but had the lowest completion rate (68.46%). Delhi had the highest (72.27%).

4. **Doctor ratings are a weak predictor of outcomes.** Doctor completion rates ranged from 53.13% to 84.85%. Doctors rated 4.5 or above completed 70.9% of treatments, compared with 68.2% for those rated below 4.0. Workload was uneven, from 26 to 66 treatments per doctor.

5. **Rooms are not used for their intended purpose.** Every room type handled every service type. Minor Surgery rooms hosted more Consultations (274) than Procedures (93).

6. **The patient base is highly returning.** 64% of patients are Regular bookers (5–9 appointments) and 23% are Frequent (10+). 500 appointments (16.7%) needed a second treatment attempt.

7. **Patient activity is similar across cities.** Appointments per patient ranged only from 6.96 to 8.16, so differences in city demand come mainly from the number of patients rather than visit frequency.

---

## ✅ Recommendations

1. **Introduce priority-based triage** so Urgent and High cases are seen first, and track waiting time by priority as a KPI.
2. **Reduce rescheduling** through better doctor and room capacity planning.
3. **Send appointment reminders** to reduce no-shows.
4. **Review capacity in Kochi**, where high demand coincides with the lowest completion rate.
5. **Reserve specialised rooms** (Minor Surgery, Diagnostic) for their intended services, and handle routine consultations in Consultation rooms.
6. **Balance doctor workloads** and evaluate doctors on treatment outcomes, not ratings alone.

---

## 💡 Key Learning

Always check the sample size before trusting an average. A city × service type × priority breakdown suggested urgent patients waited up to 45 minutes, but that figure came from a single treatment. Grouped by priority alone (hundreds of treatments per group), the difference disappeared.

---

## ▶️ How to Run

1. Open MySQL Workbench and run the schema script to create the database and tables.
2. Import the five CSV files in dependency order: `patients`, `doctors`, `rooms`, `appointments`, `treatments`.
3. Run the verification queries to confirm row counts (400 / 3,000 / 3,500 / 80 / 50).
4. Run the analysis scripts.

---

## 👤 Author

**supriya**
[LinkedIn](https://www.linkedin.com/in/supriyaj05) · [GitHub](https://github.com/supriya6676)
