CREATE OR REPLACE VIEW mrr_churn_dictionary as
SELECT 
    c.TABLE_NAME, 
    c.COLUMN_NAME, 
    c.COLUMN_TYPE, 
    c.IS_NULLABLE, 
    c.COLUMN_DEFAULT, 
    c.COLUMN_KEY, 
    c.EXTRA
FROM 
    information_schema.columns c
WHERE 
    c.TABLE_SCHEMA = 'mrr_churn'
ORDER BY 
    c.TABLE_NAME, 
    c.ORDINAL_POSITION;
    
select * from mrr_churn_dictionary;