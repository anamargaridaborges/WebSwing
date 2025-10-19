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