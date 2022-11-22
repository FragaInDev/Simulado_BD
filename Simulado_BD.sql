CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civiliza��o Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Mar�lia Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matem�tica da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Ling��stica Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ci�ncias da Computac�o pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Pol�tica',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de F�sica I',26,68.00,4,104),
(10005,'Geometria Anal�tica',1,95.00,3,105),
(10006,'Gram�tica Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de F�sica III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

/*1) Consultar nome, valor unit�rio, nome da editora e nome do autor dos livros do estoque que foram vendidos. N�o podem haver repeti��es.*/
SELECT DISTINCT e.nome as Livro, e.valor as Valor, ed.nome as Editora, a.nome as Autor
FROM estoque e, compra c, autor a, editora ed
WHERE e.codigo = c.codEstoque
	AND a.codigo = e.codAutor
	AND ed.codigo = e.codEditora

/*2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051*/
SELECT e.nome as Livro, c.qtdComprada as Quantidade, c.valor as Valor 
FROM estoque e, compra c
WHERE e.codigo = c.codEstoque
	AND c.codigo = 15051

/* Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 d�gitos, remover o www.).*/
SELECT e.nome as Livro, 
	CASE WHEN (LEN(ed.site) > 10)
		THEN SUBSTRING(ed.site,5,LEN(ed.site))
		ELSE ed.site
	END AS Website
FROM estoque e, editora ed
WHERE ed.codigo = e.codEditora
	AND ed.nome = 'Makron books'

/*4) Consultar nome do livro e Breve Biografia do David Halliday*/
SELECT a.biografia, e.nome
FROM autor a, estoque e
WHERE e.codAutor = a.codigo
	AND a.nome = 'David Halliday'

/*5) Consultar c�digo de compra e quantidade comprada do livro Sistemas Operacionais Modernos*/
SELECT c.codigo, c.qtdComprada
FROM estoque e, compra c
WHERE e.codigo = c.codEstoque
	AND e.nome LIKE 'Sistemas Operacionais%'

/*6) Consultar quais livros n�o foram vendidos*/
SELECT e.nome
FROM estoque e LEFT OUTER JOIN compra c
ON e.codigo = c.codEstoque
WHERE c.codEstoque IS NULL

/*7) Consultar quais livros foram vendidos e n�o est�o cadastrados*/
SELECT e.nome
FROM estoque e RIGHT OUTER JOIN compra c
ON e.codigo = c.codEstoque
WHERE e.codigo IS NULL

/*8) Consultar Nome e site da editora que n�o tem Livros no estoque (Caso o site tenha mais de 10 d�gitos, remover o www.)*/
SELECT ed.nome,
	CASE WHEN (LEN(ed.site) > 10)
		THEN SUBSTRING(ed.site,5,LEN(ed.site))
		ELSE ed.site
	END AS Website
FROM editora ed LEFT OUTER JOIN estoque e
ON ed.codigo = e.codEditora
WHERE e.codEditora IS NULL

/*9) Consultar Nome e biografia do autor que n�o tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)*/
SELECT a.nome,
	CASE WHEN (a.biografia LIKE 'Doutorado%')
		THEN 'Ph.D. ' + SUBSTRING(a.biografia, 10, LEN(a.biografia))
		ELSE a.biografia
	END AS Biografia
FROM autor a LEFT OUTER JOIN estoque e
ON a.codigo = e.codAutor
WHERE e.codAutor IS NULL

/*10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente*/
SELECT a.nome as Autor, e.valor
FROM autor a, estoque e
WHERE a.codigo = e.codAutor
	AND e.valor IN (
		SELECT MAX(e.valor)
		FROM estoque e, autor a
		WHERE e.codAutor = a.codigo
		
	)
ORDER BY e.valor DESC

SELECT TOP 1 a.nome as Autor, e.valor
FROM autor a, estoque e
WHERE a.codigo = e.codAutor
ORDER BY e.valor DESC

/*11) Consultar o c�digo da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por C�digo da Compra ascendente.*/
SELECT c.codigo, SUM(c.qtdComprada) AS Quantidade, SUM(c.valor) AS Gasto
FROM compra c, estoque e
WHERE c.codEstoque = e.codigo
GROUP BY c.codigo
ORDER BY c.codigo ASC

/*12) Consultar o nome da editora e a m�dia de pre�os dos livros em estoque.Ordenar pela M�dia de Valores ascendente.*/
SELECT ed.nome, CAST(AVG(e.valor) AS DECIMAL(7,2)) AS Media_Preco
FROM editora ed, estoque e
WHERE ed.codigo = e.codEditora
GROUP BY ed.nome
ORDER BY Media_Preco ASC

/*13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 d�gitos, remover o www.), criar uma coluna status onde:	
	Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
	Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
	Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
	A Ordena��o deve ser por Quantidade ascendente*/

SELECT e.nome AS Livro, e.quantidade AS Quantidade, ed.nome,
	CASE WHEN (LEN(ed.site) > 10)
		THEN SUBSTRING(ed.site,5,LEN(ed.site))
		ELSE ed.site
	END AS Website,
	CASE WHEN (e.quantidade < 5)
		THEN 'Produto em Ponto de Pedido'
		ELSE CASE WHEN (e.quantidade >=5 AND e.quantidade <=10)
				THEN 'Produto Acabando'
				ELSE 'Estoque Suficiente'
		END
	END AS Status
FROM estoque e, editora ed
WHERE e.codEditora = ed.codigo
ORDER BY e.quantidade

/*14) Para montar um relat�rio, � necess�rio montar uma consulta com a seguinte sa�da: C�digo do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
	S� pode concatenar sites que n�o s�o nulos*/
SELECT e.codigo AS Codigo_Livro, e.nome AS Nome_Livro, a.nome Nome_Autor, 
	CASE WHEN (ed.site IS NULL)
		THEN ed.nome 
		ELSE ed.nome + ' | ' + ed.site
	END AS Info_Editora
FROM estoque e, autor a, editora ed
WHERE e.codEditora = ed.codigo
	AND e.codAutor = a.codigo

/*15) Consultar Codigo da compra, quantos dias da compra at� hoje e quantos meses da compra at� hoje*/
SELECT c.codigo, DATEDIFF(DAY, c.dataCompra, GETDATE()) AS Dias, DATEDIFF(MONTH, c.dataCompra, GETDATE()) AS Meses
FROM estoque e, compra c
WHERE e.codigo = c.codEstoque
GROUP BY c.codigo, c.dataCompra

