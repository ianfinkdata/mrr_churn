CREATE OR REPLACE VIEW mrr_churn_dictionary as
SELECT 
    c.TABLE_NAME, 
    t.TABLE_TYPE,
    c.COLUMN_NAME, 
    c.COLUMN_TYPE, 
    c.IS_NULLABLE, 
    c.COLUMN_DEFAULT, 
    c.COLUMN_KEY, 
    c.EXTRA
FROM 
    information_schema.columns c
    join information_schema.tables t 
    on c.table_schema = t.table_schema
    and c.table_name = t.table_name
WHERE 
    c.TABLE_SCHEMA = 'mrr_churn'
ORDER BY 
    c.TABLE_NAME, 
    c.ORDINAL_POSITION;
    
select * from mrr_churn_dictionary;