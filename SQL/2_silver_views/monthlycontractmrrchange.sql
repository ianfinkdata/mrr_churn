create or replace view monthlycontractmrrchange as
with monthlychurn as (
select 
billing_month, 
customer_id, 
net_mrr_category,
sum(total_invoiced_cash) as revenue 
from customer_monthly_rollup
group by billing_month,customer_id, net_mrr_category
),

-- add the previous revenue
previousrevenue as (
select *, 
coalesce(lag(revenue,1) OVER(PARTITION BY customer_id ORDER BY billing_month),0) as previous_revenue,
coalesce(lead(revenue,1) OVER(PARTITION BY customer_id ORDER BY billing_month),0) as next_revenue
from monthlychurn as c
)

select * from previousrevenue
;

