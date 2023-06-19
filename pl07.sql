-- 1 )
-- a )

select nome, idade(data_nascimento) from medico where especialidade in (select id_especialidade from especialidade where designacao = 'ClÌnica Geral') and id_medico not  in (select id_medico from consulta where data_hora  between '2016-01-01' and '2016-01-31');
-- ou )

select id_medico, nome, idade(data_nascimento) from medico medico where medico.especialidade in (select id_especialidade from especialidade where designacao= 'Clinica Geral') and (select count(*) from consulta where consulta.id_medico=medico.id_medico and date_format( data_hora, '%Y-%m')='2016-01')<1;


-- b )
select nome, idade(data_nascimento) from paciente where ( select count( distinct  id_medico)  from consulta where consulta.id_paciente= paciente.id_paciente)= ( select count(*) from medico );

-- c ) 
select id_medico, nome from medico where  id_medico not in  (select  id_medico from consulta where id_paciente in (select  id_paciente from paciente where codigo_postal in (select codigo_postal from codigo_postal where localidade = 'BRAGA')));

-- d)
select nome, idade(data_nascimento), id_paciente from paciente where id_paciente in (select id_paciente from consulta  where id_medico in ( select id_medico from medico where especialidade in (select id_especialidade from especialidade where designacao ='Clínica Geral')));

-- ou )

select count(*) from consulta c1 where c1.id_paciente=p1.id_paciente and c1.medico in (select id_medico from Medico where especialidade in (select id_especialidade from especialidade where designacao='Clínica geral'))>0;

-- 2)

-- a)
select  AVG(idade(data_nascimento)) from medico where idade(data_inicio_servico)>15;

-- b)

 select designacao, avg(idade(data_inicio_servico)) from medico inner join especilidade on Medico.especialidade=especialidade.id_especialidade group by designacao;


select avg(idade(data_inicio_servico)), especialidade  from medico where especialidade in (select id_especialidade from especialidade where  designacao like '%');

-- c) 

select nome, count(*) consulta  from medico inner join consulta on consulta.id_medico=medico.id_medico group by nome;

-- d) Apresente a média de idades dos pacientes por localidade.

select  localidade, format(AVG(idade(data_nascimento)),2)  as média from paciente inner join codigo_postal on paciente.codigo_postal=codigo_postal.codigo_postal group by localidade;

-- e) 

select id_medico, nome, idade(data_nascimento) from medico 
where  medico.especialidade in (select id_especialidade 
from especialidade where designacao = 'Clinica Geral') 
and (select count(*) from consulta 
  where consulta.id_medico = medico.id_medico 
   and date_format(data_hora, '%Y-%m') = '2016-01') < 1;
   
-- select id_medico, nome, sum(preco) from consulta  where medico in ( select count(*) from consulta where consulta.id_medico=medico.id_medico and (date_format(data_hora, '%Y-%m')=' 2016-01')< 1) ;and inner join medico on consulta.preco=medico.preco group by nome;

-- select nome, Isum(preco) from consulta where consulta.id_medico=medico.id_medico and YEAR(data_hora='2016',0) valor 2016 from medico;

-- f ) 
select designacao, count(*) from medico INNER JOIN especialidade on medico.especialidade=especialidade.id_especialidade group by especialidade;

-- g)
 
select designacao, COUNT(DISTINCT C1.id_medico) numero_medicos, 
max(C1.preco) maximo, min(C1.preco) minimo,avg(C1.preco) media  FROM MEDICO M1
INNER JOIN ESPECIALIDADE ON especialidade=id_especialidade
INNER JOIN CONSULTA C1 ON M1.id_medico=C1.id_medico
GROUP BY designacao
HAVING  COUNT(DISTINCT C1.id_medico)<2;

-- or

select * from consulta, medico, especialidade
where consulta.id_medico=medico.i_medico
and medico.especialidade=especialidade.id_especialidade;

-- h ) Apresente o nome dos médicos cujo valor facturado em 2016 é superior à média desse ano.



SELECT nome, SUM(C1.preco) VAlor  FROM MEDICO M1
INNER JOIN CONSULTA C1 ON M1.id_medico=C1.id_medico
where date_format(data_hora,'%Y')='2016'
GROUP BY nome
HAVING SUM(C1.preco) > (select sum(preco)/count(distinct id_medico) from CONSULTA
where date_format(data_hora,'%Y')='2016');

-- select avg(preco) from CONSULTA where date_format(data_hora,'%Y')='2016';

-- select sum(preco)/count(distinct id_medico) from CONSULTA where date_format(data_hora,'%Y')='2016';

-- i)
select sum(consulta.preco), especialidade.designacao
from especialidade, consulta, medico
where especialidade.id_especialidade=medico.especialidade
and consulta.id_medico=medico.id_medico
and year(consulta.data_hora)='2016'
group by especialidade.designacao
order by sum(consulta.preco) desc;

-- (j) Apresente os nomes dos três médicos que deram mais consultas em 2016.

select sum(consulta.id_medico), medico.nome
from medico, consulta
where medico.id_medico=consulta.id_medico
and year(consulta.data_hora)='2016'
group by nome
limit 3;

