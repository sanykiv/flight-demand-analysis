-- Запрос 1: Ранжирование авиакомпаний по цене внутри маршрута (оконная функция RANK)
SELECT 
    "from",
    "to",
    airline,
    ROUND(AVG(price), 0) AS avg_price,
    RANK() OVER (
        PARTITION BY "from", "to" 
        ORDER BY AVG(price) DESC
    ) AS price_rank
FROM flights
WHERE class = 'Economy'
GROUP BY "from", "to", airline
ORDER BY "from", "to", price_rank;

-- Запрос 2: CTE — сегментация рейсов по ценовому уровню
WITH price_segments AS (
    SELECT 
        airline,
        class,
        price,
        "from",
        "to",
        CASE 
            WHEN price < 5000 THEN 'Бюджет'
            WHEN price BETWEEN 5000 AND 15000 THEN 'Средний'
            ELSE 'Премиум'
        END AS segment
    FROM flights
)
SELECT 
    segment,
    class,
    COUNT(*) AS flight_count,
    ROUND(AVG(price), 0) AS avg_price
FROM price_segments
GROUP BY segment, class
ORDER BY class, avg_price;

-- Запрос 3: LAG — изменение средней цены по датам (Delhi → Mumbai, Economy)
WITH daily_price AS (
    SELECT 
        date,
        ROUND(AVG(price), 0) AS avg_price
    FROM flights
    WHERE "from" = 'Delhi' 
      AND "to" = 'Mumbai'
      AND class = 'Economy'
    GROUP BY date
)
SELECT 
    date,
    avg_price,
    LAG(avg_price) OVER (ORDER BY date) AS prev_day_price,
    ROUND(avg_price - LAG(avg_price) OVER (ORDER BY date), 0) AS price_change
FROM daily_price
ORDER BY date;

