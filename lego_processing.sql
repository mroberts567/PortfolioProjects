/* How have the numbers of pieces in each new set changed over time?*/
SELECT year,
		ROUND(AVG(num_parts),0) AS avg_parts
	FROM sets
GROUP BY year
ORDER BY year;

/* Largest set published between 1950 - 2017 */
SELECT year,
		name,
		MAX(num_parts) as num_parts
	FROM sets;

/* Number of sets published each year */
SELECT year,
		COUNT(DISTINCT(set_num)) as num_sets
	FROM sets
GROUP BY year
ORDER BY year;

/* Which sets require the most colors? */
UPDATE inventory_parts -- Change color code 9999 to black color code (same RGB value)
	SET color_id = 0
	WHERE color_id = 9999;

SELECT inventory_id,
		sets.year,
		inventories.set_num,
		sets.name as set_name,
		COUNT(DISTINCT(colors.id)) AS color_count
	FROM inventory_parts
	LEFT JOIN colors
		ON inventory_parts.color_id = colors.id
		AND colors.id >-1  --remove color "unknown"
	LEFT JOIN inventories
		ON inventory_parts.inventory_id = inventories.id
	LEFT JOIN sets
		ON sets.set_num = inventories.set_num
GROUP BY sets.set_num
ORDER BY color_count DESC
LIMIT 1;

/* What percentage of sets have spare parts? */
WITH sparesCTE AS (SELECT year,
			COUNT(DISTINCT(sets.set_num)) AS num_sets_spares
		FROM inventories
		LEFT JOIN inventory_parts
			ON inventory_parts.inventory_id = inventories.id
		LEFT JOIN sets
			ON sets.set_num = inventories.set_num
	GROUP BY sets.year, inventory_parts.is_spare
	HAVING inventory_parts.is_spare = 't'),
	allCTE AS(SELECT year,
			COUNT(DISTINCT(sets.set_num)) AS num_sets
		FROM inventories
		LEFT JOIN inventory_parts
			ON inventory_parts.inventory_id = inventories.id
		LEFT JOIN sets
			ON sets.set_num = inventories.set_num
		GROUP BY sets.year)
SELECT allCTE.*,
		sparesCTE.num_sets_spares,
		CASE WHEN num_sets_spares > 0 THEN allCTE.num_sets - sparesCTE.num_sets_spares 
		ELSE allCTE.num_sets END AS num_sets_no_spares
	FROM allCTE
	LEFT JOIN sparesCTE 
		ON allCTE.year = sparesCTE.year;

		
/* Which part is the most versatile? */
SELECT parts.*,
		COUNT(DISTINCT(inventories.set_num)) AS num_sets
	FROM parts
	LEFT JOIN inventory_parts
		ON parts.part_num = inventory_parts.part_num
	LEFT JOIN inventories
		ON inventory_parts.inventory_id = inventories.id
GROUP BY parts.part_num
ORDER BY num_sets DESC
LIMIT 1;

/* Themes of sets released prior to 1960 */
SELECT sets.theme_id,
		COUNT(DISTINCT sets.set_num) AS num_sets,
		themes.*
	FROM sets
	LEFT JOIN themes
		ON sets.theme_id = themes.id
WHERE sets.year < 1960
GROUP BY themes.name
ORDER BY num_sets DESC;

/* Relationship between number of parts and number of colors */
SELECT sets.year,
		inventories.set_num,
		sets.name as set_name,
		COUNT(DISTINCT(colors.id)) AS color_count,
		sets.num_parts
	FROM inventory_parts
	LEFT JOIN colors
		ON inventory_parts.color_id = colors.id
		AND colors.id >-1  --remove color "unknown"
	LEFT JOIN inventories
		ON inventory_parts.inventory_id = inventories.id
	LEFT JOIN sets
		ON sets.set_num = inventories.set_num
GROUP BY sets.set_num
ORDER BY num_parts DESC, color_count DESC;

