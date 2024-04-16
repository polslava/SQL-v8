SELECT "ID смены" AS "ID смены",
       "Номер смены" AS "Номер смены",
       "Дата" AS "Дата",
       "Экскаватор" AS "Экскаватор",
       "ID экскаватора" AS "ID экскаватора"
FROM
  (SELECT vist_pit_shiftmonthplanfactvolume.id AS "ID смены",
          vist_pit_shiftmonthplanfactvolume.number AS "Номер смены",
          vist_pit_shiftmonthplan.date AS "Дата",
          vist_core_vehicle.name AS "Экскаватор",
          vist_core_vehicle.id AS "ID экскаватора"
   FROM vist_pit_shiftmonthplanfactvolume
   INNER JOIN vist_pit_shiftmonthplan ON vist_pit_shiftmonthplanfactvolume.plan_id = vist_pit_shiftmonthplan.id
   INNER JOIN vist_core_vehicle ON vist_pit_shiftmonthplan.shovel_id = vist_core_vehicle.id
   LIMIT 1000) AS virtual_table
LIMIT 1000;