with contractmrr as (
select 
	id as contract_id, 
	sales_rep_id, 
    go_live_deadline as live_date, 
    opt_out_eligibility, 
    contract_end_date, 
    first_month_proration, 
    final_month_proration
from contractsummary where recurring = 1
)

select * from contractmrr

/* 
example output I am expecting... asked AI to help take it from here.
contract_id, ... start_date, end_date, revenue, contract_invoice_num
20001, ... 2025-11-19, 2025-11-30, 2000, 1,
20001, ... 2025-12-01, 2025-12-31, 5000, 2, 
20001, ... 2026-01-01, 2026-01-01, 5000, 3,
20001, ... 2026-02-01, 2026-02-28, 5000, 4,
20001, ... 2026-03-01, 2026-03-31, 5000, 5,
20001, ... 2026-04-01, 2026-04-30, 5000, 6,
20001, ... 2026-05-01, 2026-01-01, 5000, 7,
20001, ... 2026-06-01, 2026-06-30, 5000, 8,
20001, ... 2026-07-01, 2026-07-31, 5000, 9,
20001, ... 2026-08-01, 2026-08-31, 5000, 10,
20001, ... 2026-09-01, 2026-09-30, 5000, 11,
20001, ... 2026-10-01, 2026-10-31, 5000, 12,
20001, ... 2026-11-01, 2026-11-18, 3000, 13
*/
;

-- ai first pass got the job done. I realized I needed to consider the cuztomer lifetime to flag new, existing, upsell, winback
CREATE OR REPLACE VIEW contractmrrsummary AS

WITH RECURSIVE contractmrr AS (
    -- 1. Your Starting Data (Added monthly_revenue)
    SELECT 
        id AS contract_id, 
        monthly_revenue,           -- Needed for the full months
        go_live_deadline AS live_date, 
        contract_end_date, 
        first_month_proration, 
        final_month_proration
    FROM contractsummary 
    WHERE recurring = 1
),
billing_schedule AS (
    -- 2. THE BASE CASE: Month 1 (The first prorated invoice)
    SELECT 
        contract_id,
        live_date AS start_date,
        LEAST(LAST_DAY(live_date), contract_end_date) AS end_date,
        first_month_proration AS revenue,
        1 AS contract_invoice_num,
        -- Carry these forward for the loop:
        monthly_revenue, contract_end_date, final_month_proration
    FROM contractmrr
    
    UNION ALL
    
    -- 3. THE RECURSIVE STEP: Invoices 2 through N
    SELECT 
        b.contract_id,
        -- Start Date: The 1st day of the next month
        DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY) AS start_date,
        
        -- End Date: The last day of the new month OR the contract end date
        LEAST(LAST_DAY(DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY)), b.contract_end_date) AS end_date,
        
        -- Revenue: If this is the final month, use the back-end proration. Otherwise, use full MRR.
        CASE 
            WHEN LAST_DAY(DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY)) = LAST_DAY(b.contract_end_date) 
            THEN b.final_month_proration
            ELSE b.monthly_revenue
        END AS revenue,
        
        b.contract_invoice_num + 1 AS contract_invoice_num,
        
        -- Carry these forward for the loop:
        b.monthly_revenue, b.contract_end_date, b.final_month_proration
    FROM billing_schedule b
    -- 4. TERMINATION CONDITION: Keep looping until we reach the end date
    WHERE b.end_date < b.contract_end_date
)
-- 5. FINAL OUTPUT
SELECT 
    contract_id, 
    start_date, 
    end_date, 
    revenue, 
    contract_invoice_num
FROM billing_schedule
WHERE revenue > 0 -- Filters out a $0 final month if a contract started exactly on the 1st
ORDER BY contract_id, contract_invoice_num;

select m.*, 
c.go_live_deadline as contract_start_date, contract_end_date, 
case when start_date = c.go_live_deadline then 'new' else 'existing' end as revenue_category
from contractmrrsummary as m
join contract as c on c.id = m.contract_id 
ORDER BY contract_id, contract_invoice_num 
;


-- needed to update to consider customer lifetime to properly flag new, existing, upsell or winback

CREATE OR REPLACE VIEW contractmrrsummary AS
WITH RECURSIVE contractmrr AS (
    -- 1. Your Starting Data (Added customer_id)
    SELECT 
        id AS contract_id, 
        customer_id,               -- ADDED
        monthly_revenue,           
        go_live_deadline AS live_date, 
        contract_end_date, 
        first_month_proration, 
        final_month_proration
    FROM contractsummary 
    WHERE recurring = 1
),
billing_schedule AS (
    -- 2. THE BASE CASE: Month 1
    SELECT 
        contract_id,
        customer_id,               -- ADDED
        live_date AS start_date,
        LEAST(LAST_DAY(live_date), contract_end_date) AS end_date,
        first_month_proration AS revenue,
        1 AS contract_invoice_num,
        monthly_revenue, contract_end_date, final_month_proration
    FROM contractmrr
    
    UNION ALL
    
    -- 3. THE RECURSIVE STEP: Invoices 2 through N
    SELECT 
        b.contract_id,
        b.customer_id,             -- ADDED
        DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY) AS start_date,
        LEAST(LAST_DAY(DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY)), b.contract_end_date) AS end_date,
        CASE 
            WHEN LAST_DAY(DATE_ADD(LAST_DAY(b.start_date), INTERVAL 1 DAY)) = LAST_DAY(b.contract_end_date) 
            THEN b.final_month_proration
            ELSE b.monthly_revenue
        END AS revenue,
        b.contract_invoice_num + 1 AS contract_invoice_num,
        b.monthly_revenue, b.contract_end_date, b.final_month_proration
    FROM billing_schedule b
    WHERE b.end_date < b.contract_end_date
)
-- 5. FINAL OUTPUT
SELECT 
    contract_id, 
    customer_id,                   -- ADDED
    start_date, 
    end_date, 
    revenue, 
    contract_invoice_num
FROM billing_schedule
WHERE revenue > 0;


WITH customer_baseline AS (
    SELECT 
        m.contract_id,
        m.customer_id,
        m.start_date,
        m.end_date,
        m.revenue,
        m.contract_invoice_num,
        c.go_live_deadline AS contract_start_date,
        
        -- The Window Function: Finds the very first go-live date for this specific customer
        MIN(c.go_live_deadline) OVER(PARTITION BY m.customer_id) AS customer_first_live_date
        
    FROM contractmrrsummary m
    JOIN contractsummary c ON c.id = m.contract_id
)
SELECT 
    contract_id,
    customer_id,
    customer_first_live_date,
    start_date,
    end_date,
    revenue,
    CASE 
        -- NEW: It is the customer's first contract, and it is the very first invoice
        WHEN contract_start_date = customer_first_live_date AND contract_invoice_num = 1 
            THEN 'New'
            
        -- UPSELL: It is a secondary contract (starts after their first live date), and it is invoice #1
        WHEN contract_start_date > customer_first_live_date AND contract_invoice_num = 1 
            THEN 'Upsell / Cross-sell'
            
        -- EXISTING: It is invoice #2 or greater on ANY contract
        ELSE 'Existing'
    END AS revenue_category
    
FROM customer_baseline
ORDER BY customer_id, start_date, contract_id;


SELECT 
    id AS contract_id, 
    signature_date AS old_signature_date, 
    DATE_SUB(signature_date, INTERVAL 1 YEAR) AS new_signature_date,
    go_live_deadline AS old_go_live_deadline
FROM contract;

-- i kicked all signature dates back by exactly 1 year to give me more space to work with for extensions, expansions, contractions and churn.
UPDATE contract 
SET signature_date = DATE_SUB(signature_date, INTERVAL 1 YEAR) where id > 20000;


-- now it's time to test out the logic by adding some renewal contracts. setting full churn aside for the moment. fed ai the output of both of these queries
select * from contract where contract_end_date <= CURDATE();

select * from mrr_churn_dictionary where table_name = 'contract' order by column_key desc;

/*  
To simulate these real-world scenarios flawlessly, I adjusted your "30 days before" logic by exactly one day.

If a contract ends on 11-18, signing the new contract exactly 30 days prior (10-19) creates a new go-live deadline of 11-18, resulting in a 1-day double-billing overlap. To make the new contract seamlessly start on the very next day (11-19), the signature date needs to be calculated 30 days prior to the new start date.

Here are the 3 scenarios designed to stress-test your MRR tracking architecture, followed by the SQL to inject them.

The 3 Scenarios
1. The Flat Renewal (Customer 10001)
	The Story: They are happy with the service and renew for another 12-month term at the exact same rate ($5,000 MRR).
	The Math: The old contract ended on 2025-11-18. The new contract goes live on 2025-11-19. The signature date is 30 days prior: 2025-10-20.
    
2. The End-of-Term Expansion (Customer 10003)
	The Story: After a successful 6-month initial term, they decide to upgrade their tier and add more seats for a new 12-month contract. Their MRR expands from $2,500 to $4,000.
	The Math: The old contract ended on 2025-09-26. The new contract goes live on 2025-09-27. The signature date is 30 days prior: 2025-08-28.

3. The Early Contraction (Customer 10010)
	The Story: They were struggling to find ROI and threatened to churn at their 90-day opt-out window (2025-08-03). Your team saved the account by downgrading their package from $3,000 to $1,500 MRR, effectively starting a fresh 12-month contract the day after their opt-out.
	The Math: The new contracted "save" goes live on 2025-08-04. The signature date is 30 days prior: 2025-07-05.

4. Opt out churn (customer 10007)
	The Story: The longer term engagement didn't develop the traction and ROI.  The team was behind in performance but had a plan in place to make up ground. The customer wasn't willing to bet anymore and opted out
	Need to determine how to handle this opt out churn in the model

*/
select * from contract order by customer_id, id;


INSERT INTO contract (
    customer_id, 
    monthly_revenue, 
    sales_rep_id, 
    signature_date, 
    opportunity_status, 
    contract_meeting_target, 
    contract_term, 
    go_live, 
    opt_out, 
    guarantee
) VALUES 
-- Scenario 1: Customer 10001 (Flat Renewal / Existing)
(10001, 5000.00, 101, '2025-10-20', 'closed won', 60, 12, 30, 1, 1),

-- Scenario 2: Customer 10003 (Expansion)
(10003, 4000.00, 102, '2025-08-28', 'closed won', 30, 12, 30, 0, 0),

-- Scenario 3: Customer 10010 (Contraction at Opt-Out)
(10010, 1500.00, 101, '2025-07-05', 'closed won', 30, 12, 30, 0, 0)
;

