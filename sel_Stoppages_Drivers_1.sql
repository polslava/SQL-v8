select q."МО",
       q."Тип МО",
q.dat,
q."Начало",
q."Окончание",
q."Длительность",
q."Простой",
q."Вид работ",
q."Аналитическая категория",
q."Организационная категория",
q."Код САП",
q."Место",
q."Дата",
q.shift,
q.model,
q.id_b,
p.fam_name,
p.first_name,
p.second_name,
p.fam_name || ' '|| substring(p.first_name from 1 for 1)|| '.'||substring(p.second_name from 1 for 1) as fio

from (
    SELECT i.vehicle_id,
       t.name                                                                         AS "МО",
       vc.name                                                                        AS "Тип МО",
       i.date                                                                         AS "Дата",
       i."time" + '08:00:00'::interval                                                AS "Начало",
       i.time_end + '08:00:00'::interval                                              AS "Окончание",
       i.time_end - i."time"                                                          AS "Длительность",
       CASE
           WHEN basetype.code = 0 AND i.idle_type_id IS NOT NULL THEN idletype.name
           ELSE basetype.name
           END                                                                        AS "Простой",
       idc.name                                                                       AS "Аналитическая категория",
       idletype.analytic_category_id,
       ido.name                                                                       AS "Организационная категория",
       idletype.organization_category_id,
       idletype.export_code                                                           AS "Код САП",
       geo.name                                                                       AS "Место",
       date(i."time")                                                                 AS dat,
       CASE
           WHEN date_part('hour'::text, i.time_end) < 12::double precision THEN 1
           ELSE 2
           END                                                                        AS shift,
       i.idle_type_id,
       model.name                                                                     AS model,
       i.base_type_code,
       concat(
               CASE
                   WHEN date_part('hour'::text, i.time_end) < 12::double precision THEN 1
                   ELSE 2
                   END, '_', i.vehicle_id, '_',
               to_char(date(i.time_end)::timestamp with time zone, 'YYYYMMDD'::text)) AS id_b,
       CASE
           WHEN basetype.code = 0 AND i.idle_type_id IS NOT NULL THEN idletype.name
           WHEN basetype.code > 0 AND i.work_type_id IS NOT NULL
               THEN concat(basetype.name, ' / ', worktype.name)::character varying
           ELSE basetype.name
           END                                                                        AS "Вид работ"
FROM v8.vist_core_intervalpointshift i
         LEFT JOIN v8.vist_core_intervalbasetype basetype ON basetype.id = i.base_type_id
         LEFT JOIN v8.vist_core_idletype idletype ON i.idle_type_id = idletype.id
         LEFT JOIN v8.vist_core_vehicle t ON i.vehicle_id = t.id
         LEFT JOIN v8.vist_core_model model ON t.model_id = model.id
         LEFT JOIN v8.vist_core_vehicletype vc ON t.vehicle_type_id = vc.id
         LEFT JOIN v8.vist_core_analyticcategory idc ON idletype.analytic_category_id = idc.id
         LEFT JOIN v8.vist_core_organizationcategory ido ON idletype.organization_category_id = ido.id
         LEFT JOIN v8.vist_core_geometry geo ON i.geometry_id = geo.id
         LEFT JOIN v8.vist_core_worktype worktype ON i.work_type_id = worktype.id

     ) q
        left join v8.vist_city_shifttask st on st.task_date = q."Дата" and st.shift_id = q.shift and q.vehicle_id = st.vehicle_id
        LEFT join v8.vist_enterprise_employee e on e.id=st.driver_id
left join v8.vist_enterprise_person p on p.id = e.person_id