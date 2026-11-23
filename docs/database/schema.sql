-- 1. Пайдаланушылар кестесі (D1)
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    iin VARCHAR(12) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL
);

-- 2. Грант міндеттемелері кестесі (D2)
CREATE TABLE grants (
    grant_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    university VARCHAR(200) NOT NULL,
    specialty VARCHAR(200) NOT NULL,
    grant_amount NUMERIC(12, 2) NOT NULL,
    required_months INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3. Өтеу өтінімдері кестесі (D3)
CREATE TABLE repayment_requests (
    request_id INT PRIMARY KEY,
    grant_id INT NOT NULL,
    reviewed_by INT,
    request_type VARCHAR(150) NOT NULL,
    submitted_at DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (grant_id) REFERENCES grants(grant_id),
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id)
);

-- 4. ЖИ тәуекел болжамдары кестесі (D4)
CREATE TABLE risk_predictions (
    prediction_id INT PRIMARY KEY,
    request_id INT NOT NULL,
    risk_score NUMERIC(5, 2) NOT NULL,
    risk_level VARCHAR(50) NOT NULL,
    predicted_at TIMESTAMP NOT NULL,
    FOREIGN KEY (request_id) REFERENCES repayment_requests(request_id)
);

-- 5. Жұмыс беруші ұйымдар кестесі (D5)
CREATE TABLE organizations (
    org_id INT PRIMARY KEY,
    bin VARCHAR(12) UNIQUE NOT NULL,
    org_name VARCHAR(200) NOT NULL,
    region VARCHAR(100) NOT NULL,
    org_type VARCHAR(150) NOT NULL
);

-- 6. Түлектер мен ұйымдар арасындағы M:N аралық кесте (D6)
CREATE TABLE graduate_organizations (
    record_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    org_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    position VARCHAR(150) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (org_id) REFERENCES organizations(org_id)
);

-- Тестілік деректер (INSERT)
INSERT INTO users VALUES
(1, 'Болатова Мөлдір', '040512600111', 'moldir@aues.kz', 'graduate'),
(2, 'Серікұлы Арман', '031120500222', 'arman@mail.kz', 'graduate'),
(3, 'Қасымова Айгүл', '040215600333', 'aigul@mail.kz', 'graduate'),
(4, 'Нұрланов Дәурен', '880714300444', 'dauren.spec@fincenter.kz', 'specialist');

INSERT INTO grants VALUES
(101, 1, 'Ғ. Дәукеев атындағы АЭжБУ', 'Ақпараттық жүйелер', 3200000.00, 36, 'active'),
(102, 2, 'Ғ. Дәукеев атындағы АЭжБУ', 'Киберқауіпсіздік', 3400000.00, 36, 'active'),
(103, 3, 'ҚазҰУ', 'Есептеу техникасы', 3100000.00, 24, 'completed');

INSERT INTO repayment_requests VALUES
(201, 101, 4, 'Жұмысқа орналасу туралы есеп', '2026-11-10', 'approved'),
(202, 102, 4, 'Өтеу мерзімін ұзарту', '2026-11-15', 'pending'),
(203, 103, 4, 'Грант өтеуді аяқтау', '2026-11-18', 'approved'),
(204, 102, 4, 'Жұмыс орнын ауыстыру', '2026-11-20', 'rejected');

INSERT INTO risk_predictions VALUES
(301, 201, 0.12, 'Төмен', '2026-11-10 10:15:00'),
(302, 202, 0.78, 'Жоғары', '2026-11-15 14:20:00'),
(303, 203, 0.05, 'Төмен', '2026-11-18 09:40:00'),
(304, 204, 0.65, 'Орташа', '2026-11-20 16:05:00');

INSERT INTO organizations VALUES
(401, '190540012345', '«Қазақтелеком» АҚ', 'Алматы', 'Ұлттық компания'),
(402, '200340054321', '«Ұлттық ақпараттық технологиялар» АҚ', 'Астана', 'Мемлекеттік мекеме'),
(403, '180940098765', '№159 мектеп-гимназия', 'Алматы', 'Білім беру ұйымы');

INSERT INTO graduate_organizations VALUES
(501, 1, 401, '2026-09-01', NULL, 'Бағдарламашы-талдаушы'),
(502, 2, 402, '2026-08-15', '2026-11-01', 'Жүйелік әкімші'),
(503, 2, 401, '2026-11-05', NULL, 'Желі инженері'),
(504, 3, 403, '2024-09-01', '2026-09-01', 'Информатика пәні мұғалімі');

-- 1-сұраныс: Кемінде 3 кестені JOIN арқылы біріктіру
SELECT
    u.full_name AS graduate_name,
    g.specialty,
    r.request_type,
    r.status AS request_status,
    p.risk_level,
    p.risk_score
FROM users u
JOIN grants g ON u.user_id = g.user_id
JOIN repayment_requests r ON g.grant_id = r.grant_id
JOIN risk_predictions p ON r.request_id = p.request_id;

-- 2-сұраныс: GROUP BY арқылы өтінімдерді мәртебесі бойынша топтау
SELECT
    status AS request_status,
    COUNT(request_id) AS total_requests
FROM repayment_requests
GROUP BY status;