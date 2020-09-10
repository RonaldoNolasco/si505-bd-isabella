use fiis;
show tables;

-- 1
explain analyze select no_empleado "Nombres", apellidos "Apellidos", no_trabajo "Cargo" from empleado e inner join trabajo t on (e.co_trabajo = t.co_trabajo);
-- Se recomienda crear un índice en el campo de co_trabajo en empleado, esto hace que el costo se reduzca de 8850 a 1627.55 y se reduzca el tiempo de ejecucion
create index idx1 on empleado (co_trabajo);
drop index idx1 on empleado;

-- 2
explain analyze select no_region "Región", no_pais "País" from region r inner join pais p on (r.co_region = p.co_region) order by no_region;
-- Como son pocos registros, no se recomienda optimización

-- 3
explain select no_region "Región", no_pais "País", de_ciudad "Ciudad", de_direccion "Dirección" from region r inner join pais p on (r.co_region = p.co_region) inner join ubicacion u on (p.co_pais = u.co_pais) ORDER BY no_region ASC, NO_PAIS DESC;
-- Igualmente no se recomienda optimizar ya que el numero de registros de las tablas es muy pequeño

-- 4
explain analyze WITH A AS (SELECT distinct(co_administrador) from empleado WHERE co_empleado = 100 or co_empleado = 125)
select no_trabajo "Trabajo", sueldo "Salario" from empleado e inner join A on (e.co_empleado = A.co_administrador) inner join trabajo t on (e.co_trabajo = t.co_trabajo) WHERE sueldo > 6000;

-- 5
explain analyze select no_empleado "Nombre", apellidos "Apellidos", no_pais "Pais" from empleado e
inner join departamento d on (e.co_departamento = d.co_departamento)
inner join ubicacion u on (d.co_ubicacion = u.co_ubicacion)
inner join pais p on (u.co_pais = p.co_pais)
WHERE no_pais LIKE 'C%';
-- Se recomienda crear un índice en el campo de co_departamente en empleado, ya que esa tabla tiene muchos registros, reduce el costo de 2918 a 480
create index idx2 on empleado (co_departamento);
drop index idx2 on empleado;

-- 6
explain WITH A as (select max(sueldo) sueldomax, co_trabajo from empleado group by co_trabajo)
SELECT no_empleado "Nombres", apellidos "Apellidos", sueldo "Salario" FROM empleado e, A where e.co_trabajo = A.co_trabajo and e.sueldo = A.sueldomax;

-- 7
WITH A as (select avg(sueldo) sueldoprom, co_trabajo from empleado group by co_trabajo)
SELECT count(co_empleado), e.co_trabajo FROM empleado e, A where e.co_trabajo = A.co_trabajo and e.sueldo >= A.sueldoprom GROUP BY e.co_trabajo;
