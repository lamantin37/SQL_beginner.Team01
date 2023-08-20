WITH cte_balance_sum AS (
	SELECT user_id, type, currency_id, SUM(money) AS volume
	FROM balance GROUP BY user_id, type, currency_id
), cte_last_rate AS (
    SELECT id AS currency_id, MAX(updated) AS last_updated
	FROM currency GROUP BY id)

SELECT COALESCE(u.name, 'not defined') AS name,
COALESCE(u.lastname, 'not defined') AS lastname,
cte_balance_sum.type,
cte_balance_sum.volume,
COALESCE(currency.name, 'not defined') AS currency_name,
COALESCE(currency.rate_to_usd, 1) AS last_rate_to_usd,
cte_balance_sum.volume::real * COALESCE(currency.rate_to_usd, 1) AS total_volume_in_usd
FROM cte_balance_sum
LEFT JOIN "user" u ON u.id = user_id
LEFT JOIN cte_last_rate ON cte_last_rate.currency_id = cte_balance_sum.currency_id
LEFT JOIN currency ON currency.id = cte_balance_sum.currency_id AND cte_last_rate.last_updated = currency.updated
ORDER BY name DESC, lastname, type;