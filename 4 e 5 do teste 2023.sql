
-- 4)
-- a
select id_paciente, nome from paciente p 
where id_paciente in ( select p.id_paciente from paciente
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on c.id_medico=m.id_medico
inner join especialidade ep on m.especialidade=ep.id_especialidade
inner join codigo_postal cp on cp.codigo_postal=p.codigo_postal
where ep.designacao='Cardiologia' AND cp.localidade='BRAGA');

-- c
select id_medico, nome from medico m 
inner join especialidade ep on m.especialidade=ep.id_especialidade
where ep.designacao='Oftalmologia';

-- b
select id_exame, designacao from exame e
where id_exame in (select e.id_exame from exame
inner join pedido_exame pe on pe.id_exame= e.id_exame 
inner join paciente p on pe.id_paciente=p.id_paciente
inner join codigo_postal cp on p.codigo_postal=cp.codigo_postal
where cp.localidade='GUIMARAES');

-- 5)

 -- a)
 select nome from medico m
 where id_medico in (select m.id_medico from medico
 inner join pedido_exame pe on pe.id_medico=m.id_medico
 where date_formart( data_pedido, '%Y')='2016');
 
 -- b)
 select nome from medico
 where id_medico not in ( select m.id_medico from medico
 inner join pedido_exame pe on pe.id_medico=m.id_medico
 inner join paciente p on p.id_paciente=pe.id_paciente
 inner join codigo_postal cp on p.codigo_postal= cp.codigo_postal
 where cp.localidade='Guimaraes');
 
 -- c)
 
select nome from paciente p
 where id_paciente in ( select id_paciente from ( select  p.id_paciente, count(distinct c.id_medico)  as total from paciente p 
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on  c.id_medico=m.id_medico 

group by p.id_paciente having total =(select count(*) from medico))M);

-- OR)
 
 select  nome from paciente p where not exists
 (select * from medico as m
 where not exists (select * from consulta c
 where c.id_paciente=p.id_paciente AND c.id_medico=m.id_medico));
 
 -- d)
 select count(*) as total from consulta c
 inner join medico m on c.id_medico=m.id_medico
 where m.nome='Manuel Maria Neves' AND date_format(data_hora, '%Y')='2016';
 
 -- 6)
DELIMITER $$ 
Alter consulta add column 'total_exames' int null default 0 

	UPDATE consulta
	set  total_exames = ( select count(*) from consulta);

-- 7)
DELIMITER $$
CREATE TRIGGER atualiza_exame
after insert on consulta
for each row
begin
UPDATE consulta 
set  num_pedidos  = (select count(*) from consulta);

END $$
DELIMITER ;
 
-- teste 2021
 
-- 5)

-- a) Quais sao o id e o nome dos paciente que foram consultados emc ardiologia
select id_paciente, nome from paciente  p
where id_paciente in (select p.id_paciente from paciente
inner join consulta c on c.id_paciente=p.id_paciente 
inner join medico m on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade=e.id_especialidade
inner join codigo_postal cp on cp.codigo_postal=p.codigo_postal
where cp.localidade='BRAGA' AND e.designacao='Cardiologia');

-- b)
select id_especialidade, designacao from especialidade e
where id_especialidade in (select e.id_especialidade from especialidade
inner join  medico m on m.especialidade=e.id_especialidade
inner join consulta c on c.id_medico=m.id_medico
inner join paciente p on c.id_paciente=p.id_paciente
inner join codigo_postal cp on p.codigo_postal=cp.codigo_postal
where cp.localidade='braga' AND idade(m.data_nascimento)>50);


-- c)
select nome from medico where idade(data_nascimento)>40;

-- 6)
-- a) O MEDICO Q DEU A TDS AS ESPECIALIDADES
select nome from medico m
where id_medico in (select id_medico from (select m.id_medico, count(distinct e.id_especialidade) as total from medico m
inner join consulta c on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade=e.id_especialidade
where 	YEAR(c.data_hora)=2016 
group by m.id_medico having total =(select count(*) from especialidade))M);


-- OR MEDICO DE CADA ESPECIALIDADE QUEM DEU EM 2016 
select nome from medico m
where id_medico in (select m.id_medico from medico m
inner join consulta c on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade=e.id_especialidade
where year(c.data_hora)=2016 
group by e.id_especialidade);

select nome from paciente p
where id_paciente in ( select id_paciente from ( select  p.id_paciente, count(distinct c.id_medico)  as total from paciente p 
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on  c.id_medico=m.id_medico 

group by p.id_paciente having total =(select count(*) from medico))M);

-- b)

select nome, idade(data_nascimento) from medico m
where id_medico not in (select m.id_medico from medico
inner join consulta c on c.id_medico=m.id_medico
inner join paciente p on c.id_paciente=p.id_paciente
inner join codigo_postal cp on p.codigo_postal=cp.codigo_postal
where cp.localidade='BRAGA');

-- c)

select nome from paciente p 
where id_paciente in (select id_paciente from (select p.id_paciente, count( distinct e.id_especialidade) as total from paciente p
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade= e.id_especialidade
group by p.id_paciente having  total= (select count(*) from especialidade))M);

select id_paciente, nome, idade(data_nascimento) from paciente p1 
where 
 (select count(distinct id_medico) 
  from consulta c1 
   where c1.id_paciente = p1.id_paciente) 
            = 
 (select count(*) 
  from medico);
  
  
  
select distinct m1.nome from medico m1
 where (select count(*) from consulta c1 
 where m1.id_medico = c1.id_medico
  and c1.id_paciente in (select id_paciente 
   from paciente where codigo_postal in (select codigo_postal 
   from codigo_postal where localidade='BRAGA'))) = 0 ;
-- d)
select count(*) from consulta c
where id_medico in (select m.id_medico from medico m
where c.id_medico=m.id_medico AND YEAR(c.data_hora)=2016 AND m.nome='José Maria');

-- OR

select count(*) from consulta c
inner join medico m on c.id_medico=m.id_medico
where year(c.data_hora)=2016 AND m.nome='José Maria';


-- pl04
-- a)
select id_paciente, nome from paciente where idade(data_nascimento)>20;
-- b)
select nome, id_medico from medico where especialidade in (select id_especialidade from especialidade e where e.designacao='Cardiologia');
-- c) 
select data_hora from consulta c where c.preco>50 Or date_format(data_hora, '%H')<12;
 
 -- PL05

-- D)  <= >=
select nome from medico where idade(data_inicio_servico)>=20;

-- E)

select nome, morada from paciente p where codigo_postal in(select codigo_postal from codigo_postal where localidade='BRAGA');


-- F)
SELECT  nome, idade(data_nascimento) from medico where especialidade in (select id_especialidade  from especialidade where designacao='Clínica Geral') and idade(data_nascimento)>40;

-- G)
SELECT nome, idade(data_nascimento) from medico m 
where id_medico in (select m.id_medico from medico m
inner join consulta c on c.id_medico=m.id_medico
inner join especialidade e on e.id_especialidade=m.especialidade
where e.designacao='Clínica Geral' AND YEAR(data_hora)=2016-01);
 
 
-- PL07
-- FUNCOES DE AGREGAÇAO E COUNT E AFINS
-- 1) 
-- a)
select nome, idade(data_nascimento) from medico m
where id_medico  in (select m.id_medico from medico m
inner join especialidade e on m.especialidade=e.id_especialidade
where e.designacao='Clínica Geral' AND (select count(*) from consulta where consulta.id_medico=m.id_medico and date_format( data_hora, '%Y-%m')='2016-01')<1);


-- b)

select nome, idade(data_nascimento) from paciente  p 
where id_paciente in(select id_paciente from (select p.id_paciente, count(distinct c.id_medico) as total from paciente p
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on c.id_medico=m.id_medico
group by p.id_paciente having total=(select count(*) from medico m))M);

-- c)

select nome from medico m 
where id_medico not in(select m.id_medico from medico m
inner join  consulta c on c.id_medico=m.id_medico
inner join paciente p on c.id_paciente=p.id_paciente
inner join codigo_postal cp on p.codigo_postal=cp.codigo_postal
where cp.localidade='BRAGA');

select distinct m1.nome from medico m1
 where (select count(*) from consulta c1 
 where m1.id_medico = c1.id_medico
  and c1.id_paciente in (select id_paciente 
   from paciente where codigo_postal in (select codigo_postal 
   from codigo_postal where localidade='BRAGA'))) = 0 ;
   

-- d)

select nome, idade(data_nascimento) from paciente  p 
where id_paciente  in (select id_paciente from (select p.id_paciente, count(distinct e.id_especialidade) as total from paciente p
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade=e.id_especialidade
group by p.id_paciente having total=(select count(*) from especialidade e where e.designacao  like 'Cliníca Geral'))M);

-- or
select nome, idade(data_nascimento) from paciente  p 
where id_paciente not in (select p.id_paciente from paciente p
inner join consulta c on c.id_paciente=p.id_paciente
inner join medico m on c.id_medico=m.id_medico
inner join especialidade e on m.especialidade=e.id_especialidade
where e.designacao!='Clínica Geral');


-- or





SELECT nome, idade(data_nascimento) Idade,
(SELECT count(*) FROM CONSULTA C1 
    WHERE C1.id_paciente=P1.id_paciente) CONTA from PACIENTE P1
WHERE (SELECT count(*) FROM CONSULTA C1 
    WHERE C1.id_paciente=P1.id_paciente AND
                C1.id_medico IN ( SELECT id_medico FROM MEDICO WHERE
          especialidade = (SELECT id_especialidade from ESPECIALIDADE
               WHERE designacao='ClÌnica Geral')))>0
    AND
                (SELECT count(*) FROM CONSULTA C1 
    WHERE C1.id_paciente=P1.id_paciente AND
                C1.id_medico IN ( SELECT id_medico FROM MEDICO WHERE
          especialidade IN (SELECT id_especialidade from ESPECIALIDADE
               WHERE designacao!='ClÌnica Geral')))=0;
                                                            
  -- se não existirem pacientes sem consultas temos o mesmo resultado com o select seguinte                                                          
 SELECT nome, idade(data_nascimento) Idade,
(SELECT count(*) FROM CONSULTA C1 
    WHERE C1.id_paciente=P1.id_paciente) CONTA from PACIENTE P1
WHERE
                (SELECT count(*) FROM CONSULTA C1 
    WHERE C1.id_paciente=P1.id_paciente AND
                C1.id_medico IN ( SELECT id_medico FROM MEDICO WHERE
          especialidade IN (SELECT id_especialidade from ESPECIALIDADE
               WHERE designacao!='ClÌnica Geral')))=0;

-- 2)

-- a)
Select AVG(idade(data_nascimento))from medico m where idade(data_inicio_servico)>15;


-- b)


select designacao, avg(idade(data_inicio_servico)) from medico m
inner join especialidade e on m.especialidade=e.id_especialidade 
group by designacao;

-- c)Apresente o numero de consultas estão registadas por médico. Devem ser apresentados todos os
-- médicos, mesmo o que nunca tenham dado consultas.


select nome, count(*) consulta  from medico inner join consulta on consulta.id_medico=medico.id_medico group by nome;
 
-- d)

select localidade,  AVG (idade(data_nascimento)) from paciente p
inner join codigo_postal cp on p.codigo_postal=cp.codigo_postal
group by localidade;
 
-- e)

select nome, (select SUM(preco) from consulta c
where c.id_medico=m.id_medico AND YEAR(c.data_hora)=2016) as total from medico m;

-- f)
select designacao,  count(*) medico from medico m
inner join especialidade e on m.especialidade=e.id_especialidade
group by designacao;

-- g)Para cada especialidade com menos de dois médicos, apresentar o valor máximo e mínimo facturadopor consulta, bem como o seu valor médio.

select designacao, MAX(c.preco)as maximo,  MIN(c.preco) as minimo, AVG(c.preco) as media from consulta c
inner join medico m on c.id_medico =m.id_medico
inner join  especialidade e on m.especialidade=e.id_especialidade
group by designacao having count(distinct c.id_medico)<=2;

-- h) Apresente o nome dos médicos cujo valor facturado em 2016 é superior à média desse ano

SELECT nome, SUM(C1.preco) VAlor  FROM MEDICO M1
INNER JOIN CONSULTA C1 ON M1.id_medico=C1.id_medico
where date_format(data_hora,'%Y')='2016'
GROUP BY nome
HAVING SUM(C1.preco) > (select sum(preco)/count(distinct id_medico) from CONSULTA
where date_format(data_hora,'%Y')='2016');


-- i)Apresente o nome(s) da(s) especialidade(s) que mais facturaram em 2016.

select designacao, sum(c.preco) from especialidade e
inner join medico m on  e.id_especialidade=m.especialidade
inner join consulta c on c.id_medico=m.id_medico
where year(c.data_hora)='2016'
group by e.designacao
order by sum(c.preco) desc;
-- j)

select nome, sum(c.id_medico) from medico m
inner join consulta c on c.id_medico=m.id_medico 
where year(c.data_hora)='2016'
group by nome
limit 3;

