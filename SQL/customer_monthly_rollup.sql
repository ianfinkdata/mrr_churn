create or replace view customer_monthly_rollup as
WITH customer_monthly_rollup AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS billing_month, 
        start_date,
        end_date,
        customer_id, 
        SUM(invoiced_revenue) AS total_invoiced_cash,
        
        -- "Bubble up" the contract-level events. 
        -- If any invoice this month has this flag, it assigns a 1 (True).
        MAX(CASE WHEN revenue_category = 'New' THEN 1 ELSE 0 END) AS is_new_month,
        MAX(CASE WHEN revenue_category = 'Expansion' THEN 1 ELSE 0 END) AS is_expansion_month,
        MAX(CASE WHEN revenue_category = 'Contraction' THEN 1 ELSE 0 END) AS is_contraction_month

    FROM contractmrr_categorized
    GROUP BY 
        DATE_FORMAT(start_date, '%Y-%m-01'), 
        start_date,
        end_date,
        customer_id
)
SELECT 
    billing_month,
    start_date,
    end_date,
    customer_id,
    total_invoiced_cash,
    
    -- Categorize the customer's month based on the bubbled-up flags
    CASE 
        WHEN is_new_month = 1 THEN 'New'
        WHEN is_expansion_month = 1 THEN 'Net Expansion'
        WHEN is_contraction_month = 1 THEN 'Net Contraction'
        
        -- If none of the above are true, it's just a standard month or a flat renewal!
        ELSE 'Flat Retention'
    END AS net_mrr_category
    
FROM customer_monthly_rollup
ORDER BY customer_id, billing_month;

select * from customer_monthly_rollup;