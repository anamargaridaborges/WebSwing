-- query para calcular a distância de match entre dois usuários
WITH RECURSIVE distancias(idUsuario, distancia, visitados) AS (
    SELECT 
        1 AS idUsuario, 
        0 AS distancia,
        ARRAY[1] AS visitados
    
    UNION ALL
    
    SELECT
        CASE
            WHEN m.IdUsuarioDeuLike = d.idUsuario THEN m.IdUsuarioRecebeuLike
            ELSE m.IdUsuarioDeuLike
        END AS idUsuario,
        d.distancia + 1 AS distancia,
        d.visitados || CASE
            WHEN m.IdUsuarioDeuLike = d.idUsuario THEN m.IdUsuarioRecebeuLike
            ELSE m.IdUsuarioDeuLike
        END AS visitados
    FROM DeuMatch m
    JOIN distancias d
        ON d.idUsuario IN (m.IdUsuarioDeuLike, m.IdUsuarioRecebeuLike)
    WHERE 
        CASE
            WHEN m.IdUsuarioDeuLike = d.idUsuario THEN m.IdUsuarioRecebeuLike
            ELSE m.IdUsuarioDeuLike
        END <> ALL(d.visitados)
        AND d.distancia < 10
)
SELECT idUsuario, MIN(distancia) AS distancia
FROM distancias
GROUP BY idUsuario
ORDER BY distancia, idUsuario;

-- query para montar o feed de um usuário
SELECT *
FROM usuario u
WHERE u.IdUsuario != 1
AND u.cidade = (SELECT cidade FROM usuario WHERE IdUsuario = 1)
AND EXISTS (
  SELECT * 
  FROM AtraidoPor ap
  WHERE ap.IdUsuario = 1
  AND ap.IdGenero = u.IdGenero
)
AND EXISTS (
  SELECT *
  FROM AtraidoPor ap
  JOIN Usuario u_logado ON u_logado.IdUsuario = 1
  WHERE ap.IdUsuario = u.IdUsuario
  AND ap.IdGenero = u_logado.IdGenero
);

-- query para estatísticas de sexualidades
-- nesse exemplo, eu calculo a porcentagem de matches
-- envolvendo homens héteros em que o rating dele é menor que o da mulher
WITH MatchesValidos AS (
  -- quero pegar todos os matches envolvendo homens héteros
    SELECT dm.IdDeuMatch,
        CASE 
            WHEN u1.IdGenero IN (3, 4) THEN u1.IdUsuario
            ELSE u2.IdUsuario
        END AS IdHomem,
        CASE 
            WHEN u1.IdGenero IN (3, 4) THEN u2.IdUsuario
            ELSE u1.IdUsuario
        END AS IdMulher
    FROM DeuMatch dm
    JOIN Usuario u1 ON u1.IdUsuario = dm.IdUsuarioDeuLike
    JOIN Usuario u2 ON u2.IdUsuario = dm.IdUsuarioRecebeuLike
   -- checo se o match seu certo e se ele envolve um homem e uma mulher
    WHERE dm.MatchSucesso = TRUE
      AND ((u1.IdGenero IN (1, 2) AND u2.IdGenero IN (3, 4))
           OR (u1.IdGenero IN (3, 4) AND u2.IdGenero IN (1, 2)))
  	-- se ele deu match com uma mulher, ele necessariamente gosta de mulheres
    -- devo checar então se ele é hetero ou bi
  	-- se ele for hetero, só existem instâncias dele no AtraidoPor relacionadas a mulheres
      AND NOT EXISTS (
          SELECT *
          FROM AtraidoPor ap
          WHERE ap.IdUsuario = 
        	CASE
        		WHEN u1.IdGenero IN (3, 4) THEN u1.IdUsuario
        		ELSE u2.IdUsuario
        	END
            AND ap.IdGenero IN (3, 4, 5, 6)
      )
),
PegarRatingDoMatch AS (
    SELECT 
        mv.*,
        r_homem.Valor AS RatingHomem,
        r_mulher.Valor AS RatingMulher
    FROM MatchesValidos mv
    JOIN Rating r_homem ON r_homem.IdUsuario = mv.IdHomem
    JOIN Rating r_mulher ON r_mulher.IdUsuario = mv.IdMulher
)
SELECT 
    COUNT(*) AS TotalMatches,
    SUM(CASE WHEN RatingHomem < RatingMulher THEN 1 ELSE 0 END) AS MatchesHomemRatingMenor,
    ROUND(
        100.0 * SUM(CASE WHEN RatingHomem < RatingMulher THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS PorcentagemHomemRatingMenor
FROM PegarRatingDoMatch;