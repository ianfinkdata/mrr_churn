/* ==============================================================================
   MRR & REVENUE RECOGNITION DATA ARCHITECTURE SUMMARY
   Description: Core DDL and DML statements used to structure the sales-to-service 
                pipeline, hardcode business logic, and automate revenue reporting.
   ============================================================================== */

-- ------------------------------------------------------------------------------
-- PART 1: STRUCTURAL INTEGRITY (DDL)
-- Ensuring Primary Keys generate automatically to prevent null value errors.
-- ------------------------------------------------------------------------------

-- 1. Fix Primary Key to Auto-Increment
ALTER TABLE contract 
MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT;


-- ------------------------------------------------------------------------------
-- PART 2: DATA INSERTION & REFERENTIAL INTEGRITY (DML)
-- Creating parent records before mapping child records with dynamic date functions.
-- ------------------------------------------------------------------------------

-- 2. Create the Parent Record (Customer)
INSERT INTO customer (customer_name, industry) 
VALUES ('New Test Corp', 'SaaS');

-- 3. Create the Child Record (Contract) using CURDATE() and mapped Foreign Key
INSERT INTO contract (
    monthly_revenue, 
    customer_id, 
    sales_rep_id, 
    signature_date, 
    opportunity_status, 
    go_live, 
    opt_out, 
    guarantee
) 
VALUES (
    5000.00, 
    10099,         -- Maps to the newly created customer.id
    101, 
    CURDATE(),     -- Automatically records the moment of insertion
    'closed won', 
    30, 
    0, 
    1
);


-- ------------------------------------------------------------------------------
-- PART 3: VIRTUAL GENERATED COLUMNS (DDL)
-- Hardcoding business rules directly into the schema to eliminate manual logic.
-- ------------------------------------------------------------------------------

-- 4. Clean up deprecated display widths from early iterations
ALTER TABLE contract
DROP COLUMN recurring;

-- 5. Automate the "Recurring" flag based on contract length (Re-added in specific order)
ALTER TABLE contract
ADD COLUMN recurring TINYINT
AS (CASE 
        WHEN contract_term > 0 THEN 1 
        ELSE 0 
    END) VIRTUAL
AFTER contract_term;

-- 6. Automate the Contract End Date (Subtracting 1 day from the Anniversary Date)
ALTER TABLE contract
ADD COLUMN contract_end_date DATE
AS (DATE_SUB(DATE_ADD(go_live_deadline, INTERVAL contract_term MONTH), INTERVAL 1 DAY)) VIRTUAL
AFTER go_live_deadline;


-- ------------------------------------------------------------------------------
-- PART 4: VERIFICATION & REPORTING (DML / DDL)
-- Joining the tables for verification and locking in the accounting view.
-- ------------------------------------------------------------------------------

-- 7. Verification Query: Ensuring the mapped records and virtual dates calculate correctly
SELECT 
    c.id AS contract_id,
    cust.customer_name,
    c.signature_date,
    c.go_live_deadline,        
    c.contract_end_date,       
    c.recurring
FROM contract c
JOIN customer cust ON c.customer_id = cust.id
WHERE cust.id = 10099;

-- 8. The "Zero-Gap" Accounting View: Automating the Rolling Deferral & Proration
CREATE OR REPLACE VIEW vw_contract_revenue_summary AS 
SELECT 
    *, 
    -- Total Contract Value
    monthly_revenue * COALESCE(contract_term, 1) AS total_revenue,
    
    -- Month 1 (Front-end Proration based on active days)
    ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS first_month_proration,
    
    -- Final Month (Back-end Proration Accounting Shortcut)
    monthly_revenue - ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS final_month_proration,
    
    -- Remaining Contract Value (Deferred Revenue moving forward)
    (monthly_revenue * COALESCE(contract_term, 1)) - ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS remaining_contract

FROM contract;


select * from mrr_churn.mrr_churn_dictionary;

select *, concat(table_name,'_',column_name) as keycolumn from mrr_churn_dictionary;

drop table dim_contract_term_mapping;