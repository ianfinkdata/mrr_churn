create or replace view customersummary as

select 
c.id, 
c.name as Customer, 
c.industry_id, 
CONCAT(c.city,', ',c.state,' ',zip) as CustomerLocation,
COUNT(cw.id) as ContractCount,
MIN(cw.signature_date) as FirstSignDate,
-- onboarding has a sign to onboard target of 90% of onboards within 90 days 
CASE 
WHEN MIN(cw.signature_date) IS NULL THEN NULL
ELSE DATE_ADD(MIN(cw.signature_date), INTERVAL 1 MONTH) 
END AS FirstProjectedLiveDate,
-- sales has a max threshold of onboarding runway to ensure they are bringing deals that wont fall down before the scheduled onboarding.
CASE 
WHEN MIN(cw.signature_date) IS NULL THEN NULL
ELSE DATE_ADD(MIN(cw.signature_date), INTERVAL 60 DAY) 
END AS ThresholdProjectedLiveDate
from customer as c 
left join contract as cw on c.id = cw.customer_id
	-- and cw.opportunity_status = 'closed won'
    
group by c.id, Customer, c.industry_id, CustomerLocation
;


select * from contract;
