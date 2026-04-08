use mrr_churn;

ALTER TABLE contract
ADD COLUMN contract_end_date DATE
AS (DATE_SUB(DATE_ADD(go_live_deadline, INTERVAL contract_term MONTH), INTERVAL 1 DAY)) VIRTUAL;


CREATE OR REPLACE VIEW contractsummary AS 

SELECT *, 
monthly_revenue * COALESCE(contract_term,1) AS total_revenue,
ROUND((monthly_revenue / go_live_month_days) * go_live_active_days,2)  AS first_month_proration,
ROUND((monthly_revenue / go_live_month_days),2) as first_month_daily_rate,
monthly_revenue * COALESCE(contract_term,1) - ROUND((monthly_revenue / go_live_month_days) * go_live_active_days,2) as remaining_contract
FROM mrr_churn.contract
;

select *
from mrr_churn.contractsummary;




