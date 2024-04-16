/*выборка простоев аварийных за смену, час
для выполнения нормы рейсов за смены
*/

SELECT sel_idle.shiftdate , sel_idle.shiftnum, sel_idle.vehicle_id,
	ROUND((SUM(EXTRACT (hour FROM (sel_idle.duration))*60 + EXTRACT (minute FROM (sel_idle.duration)))/60)::NUMERIC,2) AS idle_time
FROM (
SELECT i.date AS shiftdate, i.work_regime_detail_id AS shiftnum, i.vehicle_id, i.idle_type_id
	, i.time AS begin_time, i.time_end AS end_time
	, i.time_end - i.time AS duration
from v8.vist_core_intervalpointshift i
WHERE i.vehicle_id = 41
AND i.idle_type_id IN (
SELECT it.id FROM v8.vist_core_idletype it
	WHERE it.analytic_category_id = 1)
	) sel_idle
	where
		 sel_idle.shiftdate>=TO_timestamp('2024-01-01 ','yyyy-mm-dd')
	GROUP BY sel_idle.shiftdate , sel_idle.shiftnum, sel_idle.vehicle_id