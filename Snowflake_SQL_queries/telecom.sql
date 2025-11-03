
-- 1. Overall churn rate
SELECT ROUND(AVG(churned) * 100, 2) AS churn_rate_pct 
  FROM telecom_customers;

-- 2. Churn rate by region
SELECT region, ROUND(AVG(churned) * 100, 2) AS churn_rate_pct
  FROM telecom_customers
  GROUP BY region;

-- 3. Average tenure of churned vs retained customers
SELECT churned, ROUND(AVG(tenure_months), 2) AS avg_tenure
  FROM telecom_customers 
  GROUP BY churned;

-- 4. Churn rate by age group
SELECT FLOOR(age/10)*10 AS age_group, ROUND(AVG(churned)*100, 2) AS churn_rate_pct
  FROM telecom_customers 
  GROUP BY age_group;

-- 5. Average monthly fee of churned customers
SELECT ROUND(AVG(monthly_fee), 2) AS avg_fee 
  FROM telecom_customers 
  WHERE churned = 1;

-- 6. Average call minutes per region
SELECT c.region, ROUND(AVG(u.call_minutes), 2) AS avg_call_minutes
FROM telecom_usage u JOIN telecom_customers c ON u.customer_id = c.customer_id GROUP BY c.region;

-- 7. Correlation between data usage and monthly fee (approximate via grouping)
SELECT ROUND(u.data_gb, 0) AS data_bucket, ROUND(AVG(c.monthly_fee), 2) AS avg_fee
FROM telecom_usage u JOIN telecom_customers c ON u.customer_id = c.customer_id GROUP BY data_bucket;

-- 8. Top 10 customers by SMS usage
SELECT customer_id, sms_count FROM telecom_usage ORDER BY sms_count DESC LIMIT 10;

-- 9. Average bill amount by plan type
SELECT c.plan_type, ROUND(AVG(b.last_bill_amount), 2) AS avg_bill
FROM telecom_billing b JOIN telecom_customers c ON b.customer_id = c.customer_id GROUP BY c.plan_type;

-- 10. Percentage of unpaid or late bills
SELECT ROUND(SUM(CASE WHEN payment_status IN ('Unpaid', 'Late') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS unpaid_late_pct FROM telecom_billing;


-- 11. Average resolution time by issue type
SELECT issue_type, ROUND(AVG(resolution_time_days), 2) AS avg_resolution_time FROM telecom_tickets GROUP BY issue_type;

-- 12. Region with most unresolved tickets
SELECT c.region, COUNT(*) AS unresolved_tickets
FROM telecom_tickets t JOIN telecom_customers c ON t.customer_id = c.customer_id
WHERE resolved = 0 GROUP BY c.region ORDER BY unresolved_tickets DESC LIMIT 1;

-- 13. Ticket volume per customer
SELECT customer_id, COUNT(*) AS ticket_count FROM telecom_tickets GROUP BY customer_id;

-- 14. Resolution rate by issue type
SELECT issue_type, ROUND(AVG(resolved) * 100, 2) AS resolution_rate_pct FROM telecom_tickets GROUP BY issue_type;

-- 15. Average number of tickets per churned customer
SELECT ROUND(AVG(ticket_count), 2) AS avg_tickets
FROM (
  SELECT c.customer_id, COUNT(t.ticket_id) AS ticket_count
  FROM telecom_customers c LEFT JOIN telecom_tickets t ON c.customer_id = t.customer_id
  WHERE c.churned = 1 GROUP BY c.customer_id
) sub;


-- 16. Average latency per region
SELECT region, ROUND(AVG(latency_ms), 2) AS avg_latency FROM telecom_network_logs GROUP BY region;

-- 17. Towers with highest packet loss
SELECT tower_id, ROUND(AVG(packet_loss_pct), 2) AS avg_loss FROM telecom_network_logs GROUP BY tower_id ORDER BY avg_loss DESC LIMIT 5;

-- 18. Peak hour for network congestion
SELECT EXTRACT(HOUR FROM timestamp) AS hour, ROUND(AVG(latency_ms), 2) AS avg_latency FROM telecom_network_logs GROUP BY hour ORDER BY avg_latency DESC LIMIT 1;

-- 19. Latency during business vs off hours
SELECT
  CASE WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 8 AND 18 THEN 'Business Hours' ELSE 'Off Hours' END AS time_period,
  ROUND(AVG(latency_ms), 2) AS avg_latency
FROM telecom_network_logs GROUP BY time_period;

-- 20. Regions with consistent poor performance
SELECT region, ROUND(AVG(latency_ms), 2) AS avg_latency, ROUND(AVG(packet_loss_pct), 2) AS avg_loss
FROM telecom_network_logs GROUP BY region HAVING AVG(latency_ms) > 120 OR AVG(packet_loss_pct) > 3;

-- 21. Total revenue from postpaid customers
SELECT ROUND(SUM(monthly_fee), 2) AS total_revenue FROM telecom_customers WHERE plan_type = 'Postpaid';

-- 22. Revenue loss due to churn
SELECT ROUND(SUM(monthly_fee), 2) AS lost_revenue FROM telecom_customers WHERE churned = 1;

-- 23. Average customer lifetime value (LTV)
SELECT ROUND(AVG(monthly_fee * tenure_months), 2) AS avg_ltv FROM telecom_customers;

-- 24. Monthly revenue trend (approximate using tenure)
SELECT tenure_months, ROUND(AVG(monthly_fee), 2) AS avg_monthly_revenue FROM telecom_customers GROUP BY tenure_months ORDER BY tenure_months;

-- 25. Average revenue per region
SELECT region, ROUND(AVG(monthly_fee), 2) AS avg_revenue FROM telecom_customers GROUP BY region;

-- 26. High usage but low revenue customers
SELECT u.customer_id, u.data_gb, c.monthly_fee
FROM telecom_usage u JOIN telecom_customers c ON u.customer_id = c.customer_id
WHERE u.data_gb > 10 AND c.monthly_fee < 30;

-- 27. Customers likely to churn based on usage and billing
SELECT c.customer_id, c.churned, u.call_minutes, b.payment_status
FROM telecom_customers c JOIN telecom_usage u ON c.customer_id = u.customer_id
JOIN telecom_billing b ON c.customer_id = b.customer_id
WHERE u.call_minutes < 100 AND b.payment_status IN ('Unpaid', 'Late');

-- 28. Average tickets before churn
SELECT ROUND(AVG(ticket_count), 2) AS avg_tickets
FROM (
  SELECT c.customer_id, COUNT(t.ticket_id) AS ticket_count
  FROM telecom_customers c LEFT JOIN telecom_tickets t ON c.customer_id = t.customer_id
  WHERE c.churned = 1 GROUP BY c.customer_id
) sub;

-- 29. Relationship between network performance and churn
SELECT c.churned, ROUND(AVG(n.latency_ms), 2) AS avg_latency, ROUND(AVG(n.packet_loss_pct), 2) AS avg_loss
FROM telecom_customers c JOIN telecom_network_logs n ON c.region = n.region GROUP BY c.churned;

-- 30. Regions needing infrastructure investment
SELECT region, COUNT(*) AS high_latency_events
FROM telecom_network_logs WHERE latency_ms > 150 GROUP BY region ORDER BY high_latency_events DESC;
