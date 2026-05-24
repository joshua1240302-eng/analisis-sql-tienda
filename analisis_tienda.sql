-- ================================
-- ANÁLISIS DE TIENDA EN SQL
-- Herramienta: SQLite
-- ================================

CREATE TABLE clientes (
    id      INTEGER,
    nombre  TEXT,
    ciudad  TEXT,
    genero  TEXT
);

CREATE TABLE productos (
    id          INTEGER,
    nombre      TEXT,
    categoria   TEXT,
    precio      DECIMAL
);

CREATE TABLE pedidos (
    id          INTEGER,
    cliente_id  INTEGER,
    fecha       TEXT
);

CREATE TABLE detalle_pedidos (
    id          INTEGER,
    pedido_id   INTEGER,
    producto_id INTEGER,
    cantidad    INTEGER
);

-- Clientes
INSERT INTO clientes VALUES (1, 'Ana García', 'CDMX', 'F');
INSERT INTO clientes VALUES (2, 'Luis Pérez', 'Guadalajara', 'M');
INSERT INTO clientes VALUES (3, 'María López', 'CDMX', 'F');
INSERT INTO clientes VALUES (4, 'Carlos Ruiz', 'Monterrey', 'M');
INSERT INTO clientes VALUES (5, 'Sofia Díaz', 'Guadalajara', 'F');
INSERT INTO clientes VALUES (6, 'Pedro Mora', 'CDMX', 'M');
INSERT INTO clientes VALUES (7, 'Laura Vega', 'Monterrey', 'F');
INSERT INTO clientes VALUES (8, 'Jorge Soto', 'CDMX', 'M');

-- Productos
INSERT INTO productos VALUES (1, 'Laptop', 'Electrónica', 15000);
INSERT INTO productos VALUES (2, 'Mouse', 'Electrónica', 350);
INSERT INTO productos VALUES (3, 'Teclado', 'Electrónica', 800);
INSERT INTO productos VALUES (4, 'Monitor', 'Electrónica', 5000);
INSERT INTO productos VALUES (5, 'Audífonos', 'Electrónica', 1200);
INSERT INTO productos VALUES (6, 'Escritorio', 'Muebles', 4500);
INSERT INTO productos VALUES (7, 'Silla', 'Muebles', 3200);
INSERT INTO productos VALUES (8, 'Librero', 'Muebles', 2800);
INSERT INTO productos VALUES (9, 'Cuaderno', 'Papelería', 45);
INSERT INTO productos VALUES (10, 'Plumas', 'Papelería', 25);

-- Pedidos
INSERT INTO pedidos VALUES (1, 1, '2024-01-15');
INSERT INTO pedidos VALUES (2, 2, '2024-01-22');
INSERT INTO pedidos VALUES (3, 3, '2024-02-05');
INSERT INTO pedidos VALUES (4, 4, '2024-02-18');
INSERT INTO pedidos VALUES (5, 1, '2024-03-02');
INSERT INTO pedidos VALUES (6, 5, '2024-03-15');
INSERT INTO pedidos VALUES (7, 6, '2024-04-01');
INSERT INTO pedidos VALUES (8, 3, '2024-04-22');
INSERT INTO pedidos VALUES (9, 7, '2024-05-10');
INSERT INTO pedidos VALUES (10, 8, '2024-05-28');

-- Detalle pedidos
INSERT INTO detalle_pedidos VALUES (1, 1, 1, 1);
INSERT INTO detalle_pedidos VALUES (2, 1, 2, 2);
INSERT INTO detalle_pedidos VALUES (3, 2, 3, 1);
INSERT INTO detalle_pedidos VALUES (4, 3, 4, 1);
INSERT INTO detalle_pedidos VALUES (5, 3, 5, 2);
INSERT INTO detalle_pedidos VALUES (6, 4, 6, 1);
INSERT INTO detalle_pedidos VALUES (7, 5, 7, 2);
INSERT INTO detalle_pedidos VALUES (8, 6, 1, 1);
INSERT INTO detalle_pedidos VALUES (9, 7, 8, 1);
INSERT INTO detalle_pedidos VALUES (10, 8, 4, 2);
INSERT INTO detalle_pedidos VALUES (11, 9, 9, 10);
INSERT INTO detalle_pedidos VALUES (12, 10, 10, 20);
--PREGUNTA 1: ¿Cuantos pedidos son en total y cuantos clientes unicos hay?

SELECT 
    COUNT(*)                    AS total_pedidos,
    COUNT(DISTINCT cliente_id)  AS clientes_unicos
FROM pedidos;
--Hallazgo: 10 pedidos de 8 clientes únicos

---PREGUNTA 2:¿Cual es el producto mas caro y mas barato?
--producto mas caro
SELECT nombre, precio
From productos
ORder BY precio DESC
LIMIT 1;
--producto mas barato 
SELECT nombre, precio
FROM productos
order BY precio ASC
limit 1;
--Hallazgo : Laptop ($15,000) y Plumas ($25) son los extremos de precio
---PREGUNTA 3:¿Cuanto gasto cada cliente en total , ordenado de mayor a menor?
SELEct 
	clientes.nombre,
    SUM(productos.precio * detalle_pedidos.cantidad)  AS gasto_total
From clientes
INNER JOIN pedidos on clientes.id = pedidos.cliente_id
INNER JOIN detalle_pedidos ON pedidos.id = detalle_pedidos.pedido_id
INNER JOIN productos ON detalle_pedidos.producto_id = productos.id
GROUP BY clientes.nombre
ORDER BY gasto_total DESC;
--Hallazgo : Ana García es la cliente que más gasta con $22,100 
---PREGUNTA 4:¿Cual es la categoria de productos mas vendida por cantidad de unidades?
SELECT
	productos.categoria,
    SUM(detalle_pedidos.cantidad) as cantidad_vendida
FROM detalle_pedidos
inner join productos on detalle_pedidos.producto_id = productos.id
GROUP by productos.categoria;
--Hallazgo : Papeleria lidera en volumen con 30 unidades vendidas
---PREGUNTA 5:¿Cuantos pedidos se hicieron por mes?
SELECT
	strftime('%m', fecha) as mes,
    COUNT(*)			  AS total_pedidos
FROM pedidos
GROUP by mes
order by mes;
--Hallazgo : 2 pedidos por mes de forma constante
---PREGUNTA 6:¿Que clientes nunca han comprado un producto de Electronica?
SELECT nombre FROM clientes
Where id NOT IN (
 SELECT pedidos.cliente_id
FROM pedidos
INNER JOIN detalle_pedidos ON pedidos.id = detalle_pedidos.pedido_id
INNER JOIN productos ON detalle_pedidos.producto_id = productos.id
WHERE productos.categoria = 'Electrónica' 
);
--Hallazgo : 4 clientes nunca han comprado Electronica
---PREGUNTA 7:¿Cual es el ticket promedio por pedido?
WITH total_por_pedido AS (
    SELECT 
        pedidos.id,
        SUM(productos.precio * detalle_pedidos.cantidad) AS total
    FROM pedidos
    INNER JOIN detalle_pedidos ON pedidos.id = detalle_pedidos.pedido_id
    INNER JOIN productos ON detalle_pedidos.producto_id = productos.id
    GROUP BY pedidos.id
)
SELECT AVG(total) AS ticket_promedio
FROM total_por_pedido;
--Hallazgo :Ticket promedio de $6,355 por pedido
---PREGUNTA 8:¿Cual es el producto mas vendido por categoria?
With ventas_por_producto as (
  	SELECT 
        productos.nombre,
  		productos.categoria,
        SUM(detalle_pedidos.cantidad) AS unidades_vendidas
    FROM detalle_pedidos
    INNER JOIN productos ON detalle_pedidos.producto_id = productos.id
    GROUP BY productos.nombre, productos.categoria
),
maximo_por_categoria AS (
  	SELECT 
        categoria,
        MAX(unidades_vendidas) AS max_unidades
    FROM ventas_por_producto
    GROUP by categoria
)
SELECT 
	ventas_por_producto.categoria,
    ventas_por_producto.nombre,
    ventas_por_producto.unidades_vendidas
FROM ventas_por_producto 
inner join maximo_por_categoria
	on ventas_por_producto.categoria = maximo_por_categoria.categoria
    AND ventas_por_producto.unidades_vendidas = maximo_por_categoria.max_unidades
GROUP by ventas_por_producto.categoria;
--Hallazgo : Monitor, Silla y Plumas lideran en su categoria
---PREGUNTA 9:¿Que clientes no han realizado ningun pedido?
SELECT nombre 
FROM clientes
WHERE id NOT IN (
    SELECT cliente_id 
    FROM pedidos 
 
);
--Hallazgo : Todos los clientes han comprado al menos una vez
---PREGUNTA 10:¿Cual es el ingreso total por ciudad?
SELEct 
    clientes.ciudad,
    SUM(detalle_pedidos.cantidad * productos.precio)  AS ingreso_total
From clientes
INNER JOIN pedidos on clientes.id = pedidos.cliente_id
INNER JOIN detalle_pedidos ON pedidos.id = detalle_pedidos.pedido_id
INNER JOIN productos ON detalle_pedidos.producto_id = productos.id
GROUP BY clientes.ciudad
ORDER BY ingreso_total DESC;
--Hallazgo : CDMX genera el 67% del ingreso total