-- ________________-
-- FUNCOES 

DELIMITER $$
CREATE FUNCTION maximo_pacientes_procedimento(designacao VARCHAR(1000)) RETURNS INT
BEGIN
    DECLARE max_pacientes INT;

    -- RETORNA O MAXIMO DE PACIENTES QUE FIZERAM um dado PROCEDIMENTO 
    SELECT MAX(contagem_pacientes) INTO max_pacientes
    FROM (
        SELECT COUNT(DISTINCT pac.id_paciente) AS contagem_pacientes
        FROM paciente pac
        INNER JOIN atendimento a ON a.id_paciente = pac.id_paciente
        INNER JOIN atendimento_procedimento ap ON ap.id_atendimento = a.id_atendimento
        INNER JOIN procedimento p ON p.id_procedimento = ap.id_procedimento
        WHERE p.designacao = designacao
        
    ) AS subquery;

    RETURN max_pacientes;
END $$

SELECT maximo_pacientes_procedimento('NA');

-- _____________________________________________________________________________


DELIMITER $$
CREATE FUNCTION fn_percentagem_doentes (desig VARCHAR(100)) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE num_total INT;
    DECLARE num_doente_esp INT;
    DECLARE percentagem DECIMAL(8,2);
    
    -- Conta todos os pacientes  
    SELECT COUNT(*) INTO num_total FROM paciente p;
    
    -- Conta o número de pacientes que têm a mesma designação e estado que os parâmetros de entrada 
    SELECT COUNT(DISTINCT pd.id_paciente) INTO num_doente_esp
    FROM paciente_doenca pd
    INNER JOIN doenca d ON d.id_doenca = pd.id_doenca
    WHERE d.designacao = desig;
    
    -- Calcula a percentagem de pacientes que possuem a doença específica ou não
    SET percentagem = (num_doente_esp / num_total) * 100;
    
    RETURN percentagem;
END $$
DELIMITER ;


select fn_percentagem_doentes ('NA');

-- _________________________________________________________________________________-
DELIMITER $$
CREATE FUNCTION contar_pacientes_procedimento_data(data_procedimento DATE, designacao VARCHAR(1000))RETURNS INT
BEGIN
    DECLARE num_pacientes INT;
    
    -- Conta o número de pacientes que realizaram o procedimento a partir da data procurada
    SELECT COUNT(DISTINCT id_paciente) INTO num_pacientes
    FROM atendimento a 
    INNER JOIN atendimento_procedimento ap on ap.id_atendimento = a.id_atendimento
    INNER JOIN procedimento p on p.id_procedimento = ap.id_procedimento
    WHERE designacao = p.designacao AND data_procedimento BETWEEN a.data_entrada and a.data_saida;
    
    RETURN num_pacientes;
END $$
DELIMITER ;

SELECT contar_pacientes_procedimento_data('2009-01-13','NA');


-- ___________________________________________________________________________________________________


-- TRIGGERS 

-- ______________________________________________________________________________
DELIMITER $$
CREATE TRIGGER desconto_idade
after  insert on paciente
for each row
BEGIN
	DECLARE desconto DECIMAL (10,2);
    
    -- apresenta o valor que o paciente vai pagar caso ele tenha mais que 65 anos
    if idade(paciente.data_nacismento)>65 then 
    set desconto=0.55;
		UPDATE atendimento 
        SET montante=montante*desconto
        where paciente.id_paciente=atendimento.id_paciente ;
	end if ;
    
end $$
-- __________________________________________________________________________________________________________-
DELIMITER $$
CREATE TRIGGER tr_desconto_plano
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN
	DECLARE percentagem DECIMAL (8,2);
	-- Se apresenta plano de saúde, define a percentagem a diminuir no valor do atendimento
	IF NEW.plano_saude IS NOT NULL AND NEW.plano_saude != 0 THEN 
	SET	percentagem = 0.60;
			    
		-- Aplica a atualização do valor 
		UPDATE atendimento 
		SET montante = montante - (montante * percentagem)
		WHERE id_paciente = NEW.id_paciente;
	END IF;
END $$
DELIMITER ;
-- ______________________________________________________--



-- PROCEDIMENTOS

-- _________________________________________________________________________

DELIMITER $$
CREATE PROCEDURE pr_att_atend(id_pac INT, local_proced VARCHAR(100))
BEGIN
	DECLARE percent_local DECIMAL(8,2);
    -- Determina o percentagem a aumentar no preço do atendimento considerando o local do procedimento
    IF local_proced IS NOT NULL THEN 
		SELECT CASE
			WHEN local_proced = 'Braço' THEN 0.20
            WHEN local_proced = 'Mão' THEN 0.10
            WHEN local_proced = 'Pé' THEN 0.10
            WHEN local_proced = 'Perna' THEN 0.30
            WHEN local_proced = 'Membros superiores' THEN 0.45
			WHEN local_proced = 'Membros inferiores' THEN 0.50
            WHEN local_proced = 'Corpo todo' THEN 0.70
	ELSE 0.0
    END INTO percent_local;
	-- Atualiza o valor do montante a partir do local do procedimento 
    UPDATE atendimento 
    SET montante = montante + (montante * percent_local)
    WHERE id_paciente = id_pac;
		END IF;
END $$
DELIMITER ;

CALL pr_att_atend(1,'Mão'); -- Já funciona!!

-- __________________________________________________________________________________

SET SQL_SAFE_UPDATES = 0;
DELIMITER $$

CREATE PROCEDURE pr_atualizar_indemnizacao(id_pac INT, novo_valor DECIMAL(8,2))
BEGIN
    DECLARE dias_diff INT;
    DECLARE id_indeminizacao INT;

    -- Determina a diferença dos dias e armazena na variável local
    SELECT DATEDIFF(data_fim, data_inicio) INTO dias_diff
    FROM reclamacao r
    WHERE r.id_paciente = id_pac;

    -- Obtém o ID da indemnização
    SELECT id_indemnizacao INTO id_indeminizacao
    FROM indemnizacao
    WHERE id_reclamacao = (SELECT id_reclamacao FROM reclamacao WHERE id_paciente = id_pac);

    -- Cálculo do valor em função dos dias e atualização
    IF dias_diff IS NOT NULL AND dias_diff != 0 THEN
        UPDATE indemnizacao i SET i.valor = novo_valor * dias_diff * 1.876543
        WHERE i.id_indemnizacao = id_indeminizacao;
    ELSE
        UPDATE indemnizacao i SET i.valor = novo_valor * 1.876543
        WHERE i.id_indemnizacao = id_indeminizacao;
    END IF;
END $$

DELIMITER ;

CALL pr_atualizar_indemnizacao(1,2500); -- já funciona :)