use mrr_churn;

ALTER TABLE contract
ADD COLUMN contract_end_date DATE
AS (DATE_SUB(DATE_ADD(go_live_deadline, INTERVAL contract_term MONTH), INTERVAL 1 DAY)) VIRTUAL;


CREATE OR REPLACE VIEW contractsummary AS 

SELECT 
    *, 
    -- 1. Total Contract Value
    monthly_revenue * COALESCE(contract_term, 1) AS total_revenue,
    
    -- 2. First Month (Front-end Proration)
    ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS first_month_proration,
    
    -- 3. First Month Daily Rate
    ROUND((monthly_revenue / go_live_month_days), 2) AS first_month_daily_rate,
    
    -- 4. Final Month (Back-end Proration Shortcut)
    monthly_revenue - ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS final_month_proration,
    
    -- 5. Remaining Contract Value (After Month 1)
    (monthly_revenue * COALESCE(contract_term, 1)) - ROUND((monthly_revenue / go_live_month_days) * go_live_active_days, 2) AS remaining_contract

FROM mrr_churn.contract;
