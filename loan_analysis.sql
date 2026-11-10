Create database loan_project;
use loan_project;
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    no_of_dependents INT,
    education VARCHAR(30),
    self_employed VARCHAR(10),
    income_annum BIGINT,
    loan_amount BIGINT,
    loan_term INT,
    cibil_score INT,
    residential_assets_value BIGINT,
    commercial_assets_value BIGINT,
    luxury_assets_value BIGINT,
    bank_asset_value BIGINT,
    loan_status VARCHAR(20)
);

DESCRIBE loans;
SELECT COUNT(*) FROM loans;
SELECT * FROM loans LIMIT 5;
SELECT loan_status, COUNT(*) AS total
FROM loans
GROUP BY loan_status;

SELECT DISTINCT loan_status, LENGTH(loan_status) AS len
FROM loans;

UPDATE loans
SET loan_status = TRIM(loan_status),
    education = TRIM(education),
    self_employed = TRIM(self_employed)
WHERE loan_id > 0;

-- Q1: How many loan applications were approved and rejected?
SELECT loan_status, COUNT(*) AS total
FROM loans
GROUP BY loan_status;

-- Q2: What is the overall loan approval rate?
SELECT ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans;

-- Q3: How many applications are there for each education level?
SELECT education, COUNT(*) AS total
FROM loans
GROUP BY education;

-- Q4: How many loans were approved and rejected for each education level?
SELECT education, loan_status, COUNT(*) AS total
FROM loans
GROUP BY education, loan_status;

-- Q5: What is the approval rate for each education level?
SELECT education,
       COUNT(*) AS total_applications,
       SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS approved,
       ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans
GROUP BY education;

-- Q6: What is the average CIBIL score for approved and rejected loans?
SELECT loan_status,
       ROUND(AVG(cibil_score), 0) AS avg_cibil_score,
       MIN(cibil_score) AS min_cibil,
       MAX(cibil_score) AS max_cibil
FROM loans
GROUP BY loan_status;

-- Q7: What is the approval rate for each CIBIL score band?
SELECT
    CASE
        WHEN cibil_score < 550 THEN 'Low (300-549)'
        WHEN cibil_score < 700 THEN 'Medium (550-699)'
        ELSE 'High (700-900)'
    END AS cibil_band,
    COUNT(*) AS total_applications,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans
GROUP BY cibil_band
ORDER BY approval_rate_pct;

-- Q8: What is the approval rate for self-employed vs salaried applicants?
SELECT self_employed,
       COUNT(*) AS total_applications,
       ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans
GROUP BY self_employed;

-- Q9: What is the approval rate and average loan amount for each income group?
SELECT
    CASE
        WHEN income_annum < 3000000 THEN 'Low income (below 30L)'
        WHEN income_annum < 6000000 THEN 'Medium income (30L-60L)'
        ELSE 'High income (60L+)'
    END AS income_group,
    COUNT(*) AS total_applications,
    ROUND(AVG(loan_amount), 0) AS avg_loan_amount,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans
GROUP BY income_group
ORDER BY avg_loan_amount;

-- Q10: What is the approval rate by number of dependents?
SELECT no_of_dependents,
       COUNT(*) AS total_applications,
       ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loans
GROUP BY no_of_dependents
ORDER BY no_of_dependents;

-- Q11: Do approved applicants have higher total assets? (CTE)
WITH asset_data AS (
    SELECT loan_status,
           residential_assets_value + commercial_assets_value
           + luxury_assets_value + bank_asset_value AS total_assets
    FROM loans
)
SELECT loan_status,
       ROUND(AVG(total_assets), 0) AS avg_total_assets
FROM asset_data
GROUP BY loan_status;

-- Q12: Who are the top 3 largest approved loans in each education level? (Window function)
SELECT *
FROM (
    SELECT loan_id, education, loan_amount, cibil_score,
           RANK() OVER (PARTITION BY education ORDER BY loan_amount DESC) AS loan_rank
    FROM loans
    WHERE loan_status = 'Approved'
) ranked
WHERE loan_rank <= 3;

