-- Crime Record & Investigation Database


-- 1. Tables

CREATE TABLE officers (
    officer_id SERIAL PRIMARY KEY,
    officer_name VARCHAR(100) NOT NULL,
    rank VARCHAR(50),
    department VARCHAR(100)
);

CREATE TABLE cases (
    case_id SERIAL PRIMARY KEY,
    case_title VARCHAR(150) NOT NULL,
    case_type VARCHAR(100),
    status VARCHAR(30) DEFAULT 'Open',
    date_reported DATE DEFAULT CURRENT_DATE,
    assigned_officer_id INT,
    FOREIGN KEY (assigned_officer_id)
        REFERENCES officers(officer_id)
);

CREATE TABLE suspects (
    suspect_id SERIAL PRIMARY KEY,
    suspect_name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(20),
    case_id INT NOT NULL,
    FOREIGN KEY (case_id)
        REFERENCES cases(case_id)
);

CREATE TABLE evidence (
    evidence_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL,
    evidence_type VARCHAR(100),
    description TEXT,
    collected_date DATE DEFAULT CURRENT_DATE,
    chain_of_custody VARCHAR(100),
    FOREIGN KEY (case_id)
        REFERENCES cases(case_id)
);


-- 2. Sample Data

-- Officers
INSERT INTO officers
(officer_name, rank, department)
VALUES
('Arun Kumar', 'Inspector', 'Crime Branch'),
('Meera Nair', 'Sub Inspector', 'Cyber Cell'),
('Rahul Menon', 'Inspector', 'Investigation Unit');

-- Cases
INSERT INTO cases
(case_title, case_type, status, date_reported, assigned_officer_id)
VALUES
('City Bank Robbery', 'Robbery', 'Open', '2026-01-15', 1),
('Cyber Fraud Complaint', 'Cyber Crime', 'Solved', '2026-02-10', 2),
('Missing Person Case', 'Missing Person', 'Open', '2026-03-05', 3),
('Vehicle Theft', 'Theft', 'Solved', '2026-03-20', 1);

-- Suspects
INSERT INTO suspects
(suspect_name, age, gender, case_id)
VALUES
('Vishnu Raj', 28, 'Male', 1),
('Akhil Thomas', 32, 'Male', 2),
('Sneha Joseph', 25, 'Female', 3),
('Nikhil Das', 30, 'Male', 4);

-- Evidence
INSERT INTO evidence
(case_id, evidence_type, description, collected_date, chain_of_custody)
VALUES
(1, 'CCTV Footage',
 'Bank entrance CCTV recording',
 '2026-01-16',
 'Officer Arun Kumar'),

(2, 'Digital Record',
 'Transaction and email records',
 '2026-02-11',
 'Officer Meera Nair'),

(3, 'Photograph',
 'Photograph related to missing person',
 '2026-03-06',
 'Officer Rahul Menon'),

(4, 'Vehicle Document',
 'Recovered vehicle registration document',
 '2026-03-21',
 'Officer Arun Kumar');


-- 3. Index

CREATE INDEX idx_suspects_suspect_name
ON suspects(suspect_name);


-- 4. Case Status Analysis

SELECT
    status,
    COUNT(*) AS case_count
FROM cases
GROUP BY status
ORDER BY status;


-- 5. Officer Workload

CREATE VIEW officer_workload AS
SELECT
    o.officer_id,
    o.officer_name,
    o.rank,
    COUNT(c.case_id) AS assigned_cases
FROM officers o
LEFT JOIN cases c
    ON o.officer_id = c.assigned_officer_id
GROUP BY
    o.officer_id,
    o.officer_name,
    o.rank;

SELECT *
FROM officer_workload;


-- 6. Evidence Chain of Custody

CREATE OR REPLACE FUNCTION update_evidence_chain()
RETURNS TRIGGER AS $$
BEGIN
    NEW.chain_of_custody := 'Updated - ' || CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER evidence_chain_update
BEFORE UPDATE ON evidence
FOR EACH ROW
EXECUTE FUNCTION update_evidence_chain();


-- 7. Investigation Summary

SELECT
    c.case_id,
    c.case_title,
    c.case_type,
    c.status,
    o.officer_name,
    COUNT(DISTINCT s.suspect_id) AS suspect_count,
    COUNT(DISTINCT e.evidence_id) AS evidence_count
FROM cases c
LEFT JOIN officers o
    ON c.assigned_officer_id = o.officer_id
LEFT JOIN suspects s
    ON c.case_id = s.case_id
LEFT JOIN evidence e
    ON c.case_id = e.case_id
GROUP BY
    c.case_id,
    c.case_title,
    c.case_type,
    c.status,
    o.officer_name
ORDER BY c.case_id;


-- 8. Evidence Report

SELECT
    c.case_id,
    c.case_title,
    COUNT(e.evidence_id) AS total_evidence
FROM cases c
LEFT JOIN evidence e
    ON c.case_id = e.case_id
GROUP BY
    c.case_id,
    c.case_title
ORDER BY total_evidence DESC;


-- 9. Case and Suspect Details

SELECT
    c.case_id,
    c.case_title,
    c.status,
    s.suspect_name,
    s.age,
    s.gender
FROM cases c
LEFT JOIN suspects s
    ON c.case_id = s.case_id
ORDER BY c.case_id;


-- 10. Open Cases

SELECT
    c.case_id,
    c.case_title,
    c.case_type,
    c.date_reported,
    o.officer_name,
    o.rank
FROM cases c
LEFT JOIN officers o
    ON c.assigned_officer_id = o.officer_id
WHERE c.status = 'Open'
ORDER BY c.date_reported;


-- 11. Case Details Function

CREATE OR REPLACE FUNCTION get_case_details(p_case_id INT)
RETURNS TABLE (
    case_id INT,
    case_title VARCHAR,
    case_type VARCHAR,
    status VARCHAR,
    officer_name VARCHAR,
    suspect_name VARCHAR,
    evidence_type VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.case_id,
        c.case_title,
        c.case_type,
        c.status,
        o.officer_name,
        s.suspect_name,
        e.evidence_type
    FROM cases c
    LEFT JOIN officers o
        ON c.assigned_officer_id = o.officer_id
    LEFT JOIN suspects s
        ON c.case_id = s.case_id
    LEFT JOIN evidence e
        ON c.case_id = e.case_id
    WHERE c.case_id = p_case_id;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM get_case_details(1);