-- Create the database
CREATE DATABASE IF NOT EXISTS mrr_churn;

-- Switch to the newly created database
USE mrr_churn;

-- Create the Customer table
CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    industry_id INT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    status ENUM('prospecting', 'onboarding', 'active', 'canceled', 'winback') DEFAULT 'prospecting',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) AUTO_INCREMENT = 10001;

-- Create the Contract table
CREATE TABLE contract (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('project', 'contract') NOT NULL,
    revenue DECIMAL(15, 2) NOT NULL,
    contract_term ENUM('6 month', '12 month', '18 month', 'project') NOT NULL,
    guarantee ENUM('no guarantee', '6 month free', 'work until hit') NOT NULL,
    customer_id INT NOT NULL,
    sales_rep_id INT,
    signature_date DATE,
    opportunity_status VARCHAR(50) DEFAULT 'closed won',
    
    -- Adding a foreign key constraint to link to the customer table
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) 
        REFERENCES customer(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) AUTO_INCREMENT = 20001;