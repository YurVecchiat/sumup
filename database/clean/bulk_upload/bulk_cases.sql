INSERT INTO SUMUP.CLEAN.CASES

-- Step 1: Adjust escalation timestamps based on business rules
WITH adjusted_cases AS (
    SELECT
        *,
        CASE
            -- Weekend rule: 
            -- If escalation occurs Friday after 18:00 OR any time on Saturday/Sunday
            -- → push to next Monday at 09:00
            WHEN (
                (DATE_PART('DOW', ESCALATED_AT) = 5 AND DATE_PART('HOUR', ESCALATED_AT) >= 18)
                OR DATE_PART('DOW', ESCALATED_AT) IN (6, 0)
            )
            THEN DATE_TRUNC('WEEK', ESCALATED_AT) + INTERVAL '1 WEEK' + INTERVAL '9 HOURS'

            -- Early morning rule:
            -- If escalation occurs Monday–Friday before 09:00
            -- → set to same day at 09:00
            WHEN DATE_PART('DOW', ESCALATED_AT) BETWEEN 1 AND 5
                 AND DATE_PART('HOUR', ESCALATED_AT) < 9
            THEN DATE_TRUNC('DAY', ESCALATED_AT) + INTERVAL '9 HOURS'

            -- Evening rule:
            -- If escalation occurs Monday–Thursday after 18:00
            -- → push to next day at 09:00
            WHEN DATE_PART('DOW', ESCALATED_AT) BETWEEN 1 AND 4
                 AND DATE_PART('HOUR', ESCALATED_AT) >= 18
            THEN DATE_TRUNC('DAY', ESCALATED_AT) + INTERVAL '1 DAY' + INTERVAL '9 HOURS'

            -- Default rule:
            -- If none of the above, keep original escalation timestamp
            ELSE ESCALATED_AT
        END AS ADJUSTED_ESCALATED_AT
    FROM SUMUP.CSV.CASES
)

-- Step 2: Retrieve adjusted cases and calculate SLA metrics
SELECT
    c.CASE_ID,
    c.AGENT,
    c.MANAGER AS AGENT_MANAGER,
    c.ESCALATED_AT AS ACTUAL_ESCALATED_AT,
    c.ADJUSTED_ESCALATED_AT, -- Adjusted escalated date calculate in CTE adjusted_cases

    -- Flag indicating escalation outside working hours
    c.ESCALATED_AT != c.ADJUSTED_ESCALATED_AT AS ESCALATED_OUTSIDE_WORKING_HOURS_FLG,

    -- Flag indicating escalation occurred on a weekend
    CASE 
        WHEN DATE_PART('DOW', c.ESCALATED_AT) IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS ESCALATED_WEEKEND_FLG,

    c.FIRST_REPLY_AT AS FRT_AT,

    -- First response time in seconds from Adjust Escalated Timestamps
    DATEDIFF(SECOND, c.ADJUSTED_ESCALATED_AT, c.FIRST_REPLY_AT) AS FRT_SEC,

    -- Flag if first response met SLA (true if ≤ 6 hours from Adjust Escalated Timestamps, otherwise flase)
    DATEDIFF(SECOND, c.ADJUSTED_ESCALATED_AT, c.FIRST_REPLY_AT) <= 21600 AS FRT_SLA_MET_FLG,

    -- Flag if agent replied within scheduled work day
    s.AGENT IS NOT NULL AS FRT_IN_SCHEDULE_FLG

FROM adjusted_cases c

-- Join to schedules to verify if first reply was within agent's schedule
LEFT JOIN (SELECT AGENT, SCHEDULE_DATE FROM SUMUP.CSV.SCHEDULES) s
    ON c.AGENT = s.AGENT
    AND c.FIRST_REPLY_AT::DATE = s.SCHEDULE_DATE::DATE
;

