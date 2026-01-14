SELECT
    c.id,
    c.name,
    SUM(o.total_amount) - COALESCE(SUM(p.amount), 0) AS outstanding
FROM customers c
JOIN orders o ON o.customer_id = c.id
LEFT JOIN payments p ON p.order_id = o.id
WHERE o.created_at < now() - INTERVAL '30 days'
GROUP BY c.id
HAVING SUM(o.total_amount) - COALESCE(SUM(p.amount), 0) > 0;
