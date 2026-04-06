select distinct 
contract_term, 
guarantee, 
count(*) -- OVER(PARTITION BY contract_term, guarantee) as contracts 
from contract
group by contract_term,guarantee
order by contract_term
;
with contractsummary as (
select distinct 
contract_term, 
guarantee, 
count(*) OVER(PARTITION BY contract_term, guarantee) as contracts 
from contract 
)
select * from contractsummary
;

SELECT 
    contract_term, 
    guarantee, 
    COUNT(*) AS total_contracts,
    -- Mapping known picklist values directly to integers
    CAST(
        CASE 
            WHEN contract_term = '6 month' THEN 6
            WHEN contract_term = '12 month' THEN 12
            WHEN contract_term = '18 month' THEN 18
            WHEN contract_term = 'project' THEN 0
            ELSE NULL -- Flags newly added, unmapped picklist values for review
        END 
    AS UNSIGNED) AS numeric_contract_term_months
FROM contract
GROUP BY 
    contract_term, 
    guarantee
ORDER BY 
    numeric_contract_term_months DESC, 
    contract_term;


-- Create the dimension table
CREATE TABLE dim_contract_term_mapping (
    id INT AUTO_INCREMENT PRIMARY KEY,
    picklist_value VARCHAR(50) NOT NULL UNIQUE,
    standardized_text VARCHAR(50) NOT NULL,
    term_in_months INT NOT NULL
);

-- Insert the initial mapping values
INSERT INTO dim_contract_term_mapping (picklist_value, standardized_text, term_in_months) VALUES
('6 month', '6 Months', 6),
('12 month', '12 Months', 12),
('18 month', '18 Months', 18),
('project', 'Project', 0);

select * from dim_contract_term_mapping;

ALTER TABLE contract 
ADD COLUMN numeric_term_temp INT;

select * from contract;

ALTER TABLE contract 
DROP COLUMN contract_term;

ALTER TABLE contract 
RENAME COLUMN numeric_term_temp TO contract_term;

UPDATE contract
SET numeric_term_temp = CASE 
    WHEN contract_term = '6 month' THEN 6
    WHEN contract_term = '12 month' THEN 12
    WHEN contract_term = '18 month' THEN 18
    WHEN contract_term = 'project' THEN 0
    ELSE NULL 
END
WHERE id > 20000;
