insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

WITH cte_rates AS (
	SELECT balance.user_id,
	COALESCE(u.name, 'not defined') AS name,
	COALESCE(u.lastname, 'not defined') AS lastname,
	cur.name AS currency_name,
	balance.money,
	COALESCE(
		(SELECT rate_to_usd FROM currency
		 WHERE currency.id = balance.currency_id AND currency.updated < balance.updated
		 ORDER BY currency.updated DESC LIMIT 1),
		(SELECT rate_to_usd FROM currency
		 WHERE currency.id = balance.currency_id AND currency.updated > balance.updated
		 ORDER BY currency.updated ASC LIMIT 1)
        ) AS rate_to_usd
	FROM balance INNER JOIN (SELECT id, name FROM currency GROUP BY id, name) AS cur ON cur.id = currency_id
	LEFT JOIN "user" u ON u.id = user_id)
	
SELECT name, lastname, currency_name, (money * rate_to_usd)::real AS currency_in_usd
FROM cte_rates ORDER BY name DESC, lastname, currency_name;