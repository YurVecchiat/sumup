-- This query runs 1x day and update the data of SUMUP.CLEAN.CASES
-- Merge into logic is preferred vs delete insert for efficiency purposes

merge into SUMUP.CLEAN.CASES as TARGET -- Table to be updated

  using (
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

    -- Step 2: Select adjusted cases and calculate SLA-related columns
    SELECT
        c.CASE_ID,
        c.AGENT,
        c.MANAGER AS AGENT_MANAGER,
        c.ESCALATED_AT AS ACTUAL_ESCALATED_AT,
        c.ADJUSTED_ESCALATED_AT, -- Adjusted escalated timestamp calculated in CTE

        -- Flag indicating escalation occurred outside working hours
        c.ESCALATED_AT != c.ADJUSTED_ESCALATED_AT AS ESCALATED_OUTSIDE_WORKING_HOURS_FLG,

        -- Flag indicating escalation occurred on a weekend
        CASE 
            WHEN DATE_PART('DOW', c.ESCALATED_AT) IN (0, 6) THEN TRUE
            ELSE FALSE
        END AS ESCALATED_WEEKEND_FLG,

        c.FIRST_REPLY_AT AS FRT_AT,

        -- First Response Time in seconds from adjusted escalation
        DATEDIFF(SECOND, c.ADJUSTED_ESCALATED_AT, c.FIRST_REPLY_AT) AS FRT_SEC,

        -- Flag if first response met SLA (≤ 6 hours from adjusted escalation)
        DATEDIFF(SECOND, c.ADJUSTED_ESCALATED_AT, c.FIRST_REPLY_AT) <= 21600 AS FRT_SLA_MET_FLG,

        -- Flag if agent replied within scheduled work day
        s.AGENT IS NOT NULL AS FRT_IN_SCHEDULE_FLG

    FROM adjusted_cases c

    -- Join to schedules to verify if first reply was within agent's schedule
    LEFT JOIN (
        SELECT AGENT, SCHEDULE_DATE 
        FROM SUMUP.CSV.SCHEDULES
    ) s
    ON c.AGENT = s.AGENT
       AND c.FIRST_REPLY_AT::DATE = s.SCHEDULE_DATE::DATE

) as SOURCE -- Source dataset for the merge, containing adjusted escalations

-- Merge logic: match on CASE_ID
on TARGET.CASE_ID = SOURCE.CASE_ID

-- Insert new cases that are in the source but not yet in the target
WHEN NOT MATCHED THEN
    INSERT (
        CASE_ID, AGENT, AGENT_MANAGER, ACTUAL_ESCALATED_AT, ADJUSTED_ESCALATED_AT,
        ESCALATED_OUTSIDE_WORKING_HOURS_FLG, ESCALATED_WEEKEND_FLG, FRT_AT, FRT_SEC,
        FRT_SLA_MET_FLG, FRT_IN_SCHEDULE_FLG, ELT_INSERT_TIMESTAMP
    )
    VALUES (
        SOURCE.CASE_ID, SOURCE.AGENT, SOURCE.AGENT_MANAGER, SOURCE.ACTUAL_ESCALATED_AT,
        SOURCE.ADJUSTED_ESCALATED_AT, SOURCE.ESCALATED_OUTSIDE_WORKING_HOURS_FLG,
        SOURCE.ESCALATED_WEEKEND_FLG, SOURCE.FRT_AT, SOURCE.FRT_SEC,
        SOURCE.FRT_SLA_MET_FLG, SOURCE.FRT_IN_SCHEDULE_FLG, CURRENT_TIMESTAMP
    )

-- Update the FRT and AGENT columns of existing cases where FRT_AT is null (i.e. all cases that were creted but not answered yet)
WHEN MATCHED AND TARGET.FRT_AT IS NULL THEN
    UPDATE SET
        AGENT = SOURCE.AGENT, 
        AGENT_MANAGER = SOURCE.AGENT_MANAGER,
        FRT_AT = SOURCE.FRT_AT,
        FRT_SEC = SOURCE.FRT_SEC,
        FRT_SLA_MET_FLG = SOURCE.FRT_SLA_MET_FLG,
        FRT_IN_SCHEDULE_FLG = SOURCE.FRT_IN_SCHEDULE_FLG,
        ELT_INSERT_TIMESTAMP = CURRENT_TIMESTAMP();
