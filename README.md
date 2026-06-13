# Data-Driven Support Operations: Analyzing Ticket Friction, Channels, and Data Integrity

## 📌 Project Overview
This project delivers an end-to-end operational audit and performance analysis of **8,077 customer support records**. By executing a rigorous data quality validation check, a critical system-wide timestamp corruption affecting **83.1% of the dataset** was uncovered and isolated. 

Proceeding with a statistically sound, clean sample ($N = 1,365$), this study utilizes advanced SQL aggregations and statistical correlation functions (`CORR`) within BigQuery to identify true drivers of Customer Satisfaction (CSAT), evaluate support channel efficiencies.

### 🛠️ Tech Stack & Skills
* **SQL Dialect:** Google BigQuery Standard SQL
* **Key Functions:** Common Table Expressions (CTEs), Statistical Correlation (`CORR`), Chronological Timestamp Offsets (`TIMESTAMP_DIFF`), Logical Filtering, Aggregation.
* **Analytical Concepts:** Data Quality Auditing, Sample Size Justification ($N > 1,000$), Feature Isolation, Root Cause Analysis.

---

## 🔍 Phase 1: Data Quality Audit & Integrity Constraints

Before executing performance KPIs, a logical validation constraint was run to ensure chronological integrity across the helpdesk pipeline:

$$\text{Constraint Check: } \text{Time to Resolution} \ge \text{First Response Time}$$

### ⚠️ The Finding
An alarming **6,712 rows (83.1% of the dataset)** fundamentally failed this constraint, exhibiting impossible "time-traveling" data entry anomalies where tickets were recorded as resolved *before* an initial agent response occurred.

### 🛠️ The Mitigation Strategy
Rather than analyzing corrupted data, which would introduce heavily skewed negative durations into business metrics, the broken records were systematically isolated. The analysis safely proceeded using the remaining **1,365 valid records**.

> **Statistical Justification:** A clean subset of $1,365$ rows represents a highly viable statistical sample size ($N > 1,000$). Governed by the Law of Large Numbers and Central Limit Theorem, this sample keeps the margin of error constrained to a tiny **$\approx 2.6\%$**, ensuring all derived operational insights remain dependable for leadership deployment.

---

## 📈 Phase 2: Core Business Insights & SQL Pipeline

### 1. Product Ticket Volume vs. Satisfaction
* **Business Question:** *Which products generate the heavy lifting for the support desk, and where are the quality gaps?*

### 2. Resolution Efficiency by Ticket Priority
* **Business Question:** *Which priorities require the longest resolution times, and does the desk triage correctly?*

### 3. High-Performing Support Channels
* **Business Question:** *Which support channels optimize the customer experience based on CSAT?*

### 4. Friction Analysis: Ticket Categories & Issue Subjects
* **Business Question:** *Which ticket subjects drive down customer satisfaction?*

*(Note: Full optimized SQL scripts mapping to each business question are available in the `/csat_queries` directory).*

---

## 🧪 Phase 3: Advanced Statistical Correlation

* **Business Question:** *Are customer satisfaction scores strictly tied to the speed of ticket resolution?*

To isolate the relationship between resolution speeds and customer satisfaction, BigQuery’s Pearson correlation coefficient function (`CORR`) was applied to the audited dataset.

### 📊 Strategic Findings
* **Correlation Coefficient Output:** `-0.005`
* **The Breakdown:** A metric this close to absolute zero proves there is **virtually no linear relationship** between the duration a ticket takes to resolve and the final CSAT score.
* **Executive Takeaway:** Speed is not the primary driver of customer happiness. Operational focus should shift from rushing ticket closures to qualitative metrics—such as First-Contact Resolution (FCR) rates, agent empathy, and clear communication frameworks.

---

## 🎯 Final Operational Recommendations

* **Fix the Logging Pipeline Immediately:** The IT/Data Engineering team must investigate the database race condition or application time-sync logging bug causing 83% of tickets to stamp incorrect chronological data.
* **Optimize High-Friction Categories:** Target the ticket types identified in the lowest-scoring categories for automated help documentation or specialized tier-2 agent training.
* **De-emphasize Speed as a Lone Metric:** Cancel arbitrary processing speed metrics. Since resolution time has a neutral correlation to CSAT, re-align team performance bonuses around response accuracy and ticket re-open rates over raw handling times.

---

## 📂 How to Explore this Project
* `/csat_queries`: Contains full, optimized `.sql` scripts used during data validation and analysis.

***
*Designed and developed as a core data analytics portfolio project.*
