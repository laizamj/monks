-- 1) Ordene os dias da semana por faturamento médio de corrida. 
-- Selecione o dia com maior faturamento médio de corrida e exiba o 
-- faturamento por dia para esse dia da semana.

-- Verificar cada dia da semana e seu faturamento médio
WITH DayOfWeek AS (
    SELECT 
        strftime('%w', pickup_datetime) AS day_of_week,  -- Dia da semana de cada data (0=domingo, 1=segunda, ..., 6=sábado)
        total_amount
    FROM planilha_tabela
),
-- Ordenando por faturamento médio
AverageRevenuePerDay AS (
    SELECT 
        day_of_week,
        AVG(total_amount) AS avg_revenue
    FROM DayOfWeek
    GROUP BY day_of_week
)
-- dia da semana com maior faturamento médio
SELECT 
    day_of_week, avg_revenue
FROM AverageRevenuePerDay
ORDER BY avg_revenue DESC
LIMIT 1;

-- Com isso, nota-se que o dia da semana com maior faturamento médio é o domingo, com média de 40.92
-- de faturamento por dia




-- 2) Considere que corridas de táxi válidas tenham de 1 a 5 passageiros. Qual a
-- quantidade de corridas feitas com cada número de passageiros, valor médio de
-- cada corrida e faturamento médio por passageiro?

WITH ValidTrips AS (
    SELECT 
        passenger_count,
        total_amount,
        fare_amount
    FROM planilha_tabela
    WHERE passenger_count BETWEEN 1 AND 5
),

TripStats AS (
    SELECT 
        passenger_count,
        COUNT(*) AS num_trips, -- Número de corridas
        AVG(total_amount) AS avg_total_amount_per_trip, -- Valor total médio de cada corrida
        AVG(total_amount / passenger_count) AS avg_revenue_per_passenger -- Faturamento médio por passageiro
    FROM ValidTrips
    GROUP BY passenger_count
)

SELECT 
    passenger_count,
    num_trips,
    avg_total_amount_per_trip,
    avg_revenue_per_passenger
FROM TripStats;

-- Com isso, obtemos uma consulta com a quantidade de corridas (num_trips) feitas com cada número de passageiros.
-- Além disso, também temos o valor médio de cada corrida avg_total_amount_per_trip) e o faturamento médio por passageiro 
-- (avg_revenue_per_passenger).




-- 3) Calcule a quantidade de corridas válidas diárias e determine a diferença
-- percentual em relação ao dia anterior para cada dia.

-- Quantidade de corridas válidas diárias
WITH DailyTrips AS (
    SELECT 
        DATE(pickup_datetime) AS trip_date, -- Data da corrida
        COUNT(*) AS num_trips -- Número de corridas por dia
    FROM planilha_tabela
    WHERE passenger_count BETWEEN 1 AND 5 -- Corridas válidas
    GROUP BY trip_date
),

-- Diferença percentual em relação ao dia anterior
DailyTripDifferences AS (
    SELECT 
        trip_date,
        num_trips,
        LAG(num_trips) OVER (ORDER BY trip_date) AS prev_day_trips, -- Corridas do dia anterior
        CASE
            WHEN LAG(num_trips) OVER (ORDER BY trip_date) IS NULL THEN NULL
            ELSE (num_trips - LAG(num_trips) OVER (ORDER BY trip_date)) * 100.0 / LAG(num_trips) OVER (ORDER BY trip_date)
        END AS pct_change -- Diferença percentual em relação ao dia anterior
    FROM DailyTrips
)
SELECT 
    trip_date,
    num_trips,
    pct_change
FROM DailyTripDifferences
ORDER BY trip_date;

-- Nessa consulta temos a data da corridas com a quantidade de corridas naquela data e a 
-- diferença percentual em relaçao aos dias anteriores.




-- 4) Calcule e compare a média de gorjeta destes dois grupos:
---- a) O grupo das corridas que houveram pedágios (tolls) e que possui até 3 passageiros;
---- b) E das que não houveram pedágios e que possuem 4 ou mais passageiros

-- Média de gorjeta para o Grupo A
WITH GroupA AS (
    SELECT 
        tip_amount
    FROM planilha_tabela
    WHERE tolls_amount > 0 AND passenger_count <= 3
),

-- Média de gorjeta para o Grupo B
GroupB AS (
    SELECT 
        tip_amount
    FROM planilha_tabela
    WHERE tolls_amount = 0 AND passenger_count >= 4
),

-- Comparar as médias de gorjeta entre os dois grupos
TipComparison AS (
    SELECT 
        'Grupo A' AS group_name,
        AVG(tip_amount) AS avg_tip_amount
    FROM GroupA
    UNION ALL
    SELECT 
        'Grupo B' AS group_name,
        AVG(tip_amount) AS avg_tip_amount
    FROM GroupB
)


SELECT 
    group_name,
    avg_tip_amount
FROM TipComparison;

-- Com isso notamos que o grupo A, com 6.23 em gorjetas, tem uma média de gorjetas bem maior que o grupo B, com 3.42.demo


