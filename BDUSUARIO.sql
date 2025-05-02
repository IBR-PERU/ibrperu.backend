CREATE DATABASE DB_USUARIO;

GO

USE DB_USUARIO;

GO

CREATE TABLE Addresses
(
  IdAddress INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Street    NVARCHAR(100) NULL,
  Suite     NVARCHAR(50)  NULL,
  City      NVARCHAR(50)  NULL,
  Zipcode   NVARCHAR(20)  NULL,
  Lat       DECIMAL(9,6)  NULL,
  Lng       DECIMAL(9,6)  NULL
);
GO

CREATE TABLE Company
(
  IdCompany    INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Names         NVARCHAR(100) NULL,
  CatchPhrase  NVARCHAR(200) NULL,
  Bs           NVARCHAR(100) NULL
);
GO

CREATE TABLE Usuario
(
  IdUsuario   INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Names       NVARCHAR(100) NULL,
  Username    NVARCHAR(50)  NULL,
  Email       NVARCHAR(100) NULL,
  Phone       NVARCHAR(50)  NULL,
  Website     NVARCHAR(100) NULL,
  IdAddress   INT           NOT NULL CONSTRAINT FK_Usuario_Address FOREIGN KEY REFERENCES Addresses(IdAddress),
  IdCompany   INT           NOT NULL CONSTRAINT FK_Usuario_Company FOREIGN KEY REFERENCES Company(IdCompany)
);

GO

INSERT INTO Addresses (Street, Suite, City, Zipcode, Lat, Lng)
VALUES
('Kulas Light',       'Apt. 556',  'Gwenborough',      '92998-3874',   -37.315900,  81.149600),
('Victor Plains',     'Suite 879', 'Wisokyburgh',      '90566-7771',   -43.950900, -34.461800),
('Douglas Extension', 'Suite 847', 'McKenziehaven',    '59590-4157',   -68.610200, -47.065300),
('Hoeger Mall',       'Apt. 692',  'South Elvis',      '53919-4257',    29.457200, -164.299000),
('Skiles Walks',      'Suite 351', 'Roscoeview',       '33263',         -31.812900,  62.534200),
('Norberto Crossing', 'Apt. 950',  'South Christy',    '23505-1337',   -71.419700,  71.747800),
('Rex Trail',         'Suite 280', 'Howemouth',        '58804-1099',    24.891800,  21.898400),
('Ellsworth Summit',  'Suite 729', 'Aliyaview',        '45169',        -14.399000,-120.767700),
('Dayna Park',        'Suite 449', 'Bartholomebury',   '76495-3109',    24.646300,-168.888900),
('Kattie Turnpike',   'Suite 198', 'Lebsackbury',      '31428-2261',   -38.238600,  57.223200);

GO

INSERT INTO Company (Names, CatchPhrase, Bs)
VALUES
('Romaguera-Crona',            'Multi-layered client-server neural-net',       'harness real-time e-markets'),
('Deckow-Crist',               'Proactive didactic contingency',               'synergize scalable supply-chains'),
('Romaguera-Jacobson',         'Face to face bifurcated interface',            'e-enable strategic applications'),
('Robel-Corkery',              'Multi-tiered zero tolerance productivity',     'transition cutting-edge web services'),
('Keebler LLC',                'User-centric fault-tolerant solution',         'revolutionize end-to-end systems'),
('Considine-Lockman',          'Synchronised bottom-line interface',           'e-enable innovative applications'),
('Johns Group',                'Configurable multimedia task-force',           'generate enterprise e-tailers'),
('Abernathy Group',            'Implemented secondary concept',                'e-enable extensible e-tailers'),
('Yost and Sons',              'Switchable contextually-based project',        'aggregate real-time technologies'),
('Hoeger LLC',                 'Centralized empowering task-force',            'target end-to-end models');

GO


INSERT INTO Usuario (Names, Username, Email, Phone, Website, IdAddress, IdCompany)
VALUES
('Leanne Graham',           'Bret',            'Sincere@april.biz',          '1-770-736-8031 x56442',    'hildegard.org',   1,  1),
('Ervin Howell',            'Antonette',       'Shanna@melissa.tv',          '010-692-6593 x09125',      'anastasia.net',   2,  2),
('Clementine Bauch',        'Samantha',        'Nathan@yesenia.net',         '1-463-123-4447',           'ramiro.info',     3,  3),
('Patricia Lebsack',        'Karianne',        'Julianne.OConner@kory.org',  '493-170-9623 x156',        'kale.biz',        4,  4),
('Chelsey Dietrich',        'Kamren',          'Lucio_Hettinger@annie.ca',   '(254)954-1289',            'demarco.info',    5,  5),
('Mrs. Dennis Schulist',    'Leopoldo_Corkery','Karley_Dach@jasper.info',    '1-477-935-8478 x6430',     'ola.org',         6,  6),
('Kurtis Weissnat',         'Elwyn.Skiles',    'Telly.Hoeger@billy.biz',     '210.067.6132',             'elvis.io',        7,  7),
('Nicholas Runolfsdottir V','Maxime_Nienow',   'Sherwood@rosamond.me',       '586.493.6943 x140',        'jacynthe.com',    8,  8),
('Glenna Reichert',         'Delphine',        'Chaim_McDermott@dana.io',    '(775)976-6794 x41206',     'conrad.com',      9,  9),
('Clementina DuBuque',      'Moriah.Stanton',  'Rey.Padberg@karina.biz',     '024-648-3804',             'ambrose.net',    10, 10);


GO

CREATE SCHEMA seguridad

GO

CREATE PROCEDURE seguridad.pa_usuario
AS
BEGIN
    SELECT
        U.IdUsuario,
        U.Names AS NamesUser,
        U.Username,
        U.Email,
        U.Phone,
        U.Website,
        U.IdAddress,
        C.Names AS NamesCompany,
		C.CatchPhrase,
		C.Bs
    FROM
		Usuario U
		INNER JOIN Company C ON C.IdCompany = U.IdCompany
END

GO

CREATE PROCEDURE seguridad.pa_usuario;2
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IdUsuario,
        U.Names AS NamesUser,
        U.Username,
        U.Email,
        U.Phone,
        U.Website,
        U.IdAddress,
        C.Names AS NamesCompany,
		C.CatchPhrase,
		C.Bs
    FROM
		Usuario U
		INNER JOIN Company C ON C.IdCompany = U.IdCompany
	WHERE
		IdUsuario = @IdUsuario
END

GO

ALTER PROCEDURE seguridad.pa_usuario;3
    @NamesUser     NVARCHAR(100),
    @Username      NVARCHAR(50),
    @Email         NVARCHAR(100),
    @Phone         NVARCHAR(50),
    @Website       NVARCHAR(100),
    @Street        NVARCHAR(100),
    @Suite         NVARCHAR(50),
    @City          NVARCHAR(50),
    @Zipcode       NVARCHAR(20),
    @Lat           DECIMAL(9,6),
    @Lng           DECIMAL(9,6),
    @CompanyNames  NVARCHAR(100),
    @CatchPhrase   NVARCHAR(200),
    @Bs            NVARCHAR(100)
AS
BEGIN

    BEGIN TRANSACTION;
		DECLARE @NewAddressId INT, @NewCompanyId INT;

 
		INSERT INTO Addresses (Street, Suite, City, Zipcode, Lat, Lng)
		VALUES (@Street, @Suite, @City, @Zipcode, @Lat, @Lng);
		SET @NewAddressId = SCOPE_IDENTITY();

		-- 2) Insertar en Company
		INSERT INTO Company (Names, CatchPhrase, Bs)
		VALUES (@CompanyNames, @CatchPhrase, @Bs);
		SET @NewCompanyId = SCOPE_IDENTITY();

		-- 3) Insertar en Usuario
		INSERT INTO Usuario
			(Names, Username, Email, Phone, Website, IdAddress, IdCompany)
		VALUES
			(@NamesUser, @Username, @Email, @Phone, @Website, @NewAddressId, @NewCompanyId);

    COMMIT TRANSACTION;
END
GO