create or replace view executive_mrr_change_gold as 
select 
billing_month, 
customer_id, 
sum(revenue) as "Current Month Revenue",
sum(previous_revenue) as "Previous Month Revenue",
sum(revenue) - sum(previous_revenue) as "Net MRR Change",
coalesce(((sum(revenue) - sum(previous_revenue))/ sum(previous_revenue)),1) *.01 as "Net MRR Percent Change"
from monthlycontractmrrchange
group by billing_month, customer_id
order by customer_id, billing_month
;

select * from executive_mrr_change_gold;



