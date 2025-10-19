CREATE TABLE IF NOT EXISTS Genero(
    IdGenero INT PRIMARY KEY NOT NULL,
    Nome VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Usuario(
    IdUsuario INT PRIMARY KEY,
    Cidade VARCHAR(50) NOT NULL,
    DataNascimento DATE NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Bio VARCHAR(280) NOT NULL,
    IdGenero INTEGER NOT NULL,
    FOREIGN KEY (IdGenero) REFERENCES Genero(IdGenero)
);

CREATE TABLE IF NOT EXISTS FotoUsuario(
    IdFoto INT PRIMARY KEY,
    IdUsuario INTEGER NOT NULL,
    UrlFoto VARCHAR(100) NOT NULL,
    FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
);

CREATE TABLE IF NOT EXISTS AtraidoPor(
    IdAtracao INT PRIMARY KEY NOT NULL,
    IdUsuario INT NOT NULL,
    IdGenero INT NOT NULL,
    FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario),
    FOREIGN KEY (IdGenero) REFERENCES Genero(IdGenero)
);

CREATE TABLE IF NOT EXISTS Rating(
    IdRating INT PRIMARY KEY,
    DataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Valor NUMERIC NOT NULL,
    IdUsuario INTEGER NOT NULL,
    FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
);

CREATE TABLE IF NOT EXISTS Visualizou(
    IdVisualizou INT PRIMARY KEY,
    DataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioVisualizador INTEGER NOT NULL,
    IdUsuarioVisualizado INTEGER NOT NULL,
    FOREIGN KEY (IdUsuarioVisualizador) REFERENCES Usuario(IdUsuario),
    FOREIGN KEY (IdUsuarioVisualizado) REFERENCES Usuario(IdUsuario)
);

CREATE TABLE IF NOT EXISTS DeuMatch(
    IdDeuMatch INT PRIMARY KEY,
    DataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    MatchSucesso BOOLEAN NOT NULL,
    IdUsuarioDeuLike INTEGER NOT NULL,
    IdUsuarioRecebeuLike INTEGER NOT NULL,
    FOREIGN KEY (IdUsuarioDeuLike) REFERENCES Usuario(IdUsuario),
    FOREIGN KEY (IdUsuarioRecebeuLike) REFERENCES Usuario(IdUsuario)
);

CREATE TABLE IF NOT EXISTS Avaliacao(
    IdAvaliacao INT PRIMARY KEY,
    DataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Comentario VARCHAR(280),
    Valor INT NOT NULL,
    IdUsuarioEscritor INTEGER NOT NULL,
    IdUsuarioReceptor INTEGER NOT NULL,
    FOREIGN KEY (IdUsuarioEscritor) REFERENCES Usuario(IdUsuario),
    FOREIGN KEY (IdUsuarioReceptor) REFERENCES Usuario(IdUsuario)
);
