CREATE OR REPLACE TABLE SUMUP.CLEAN.CASES (
    CASE_ID                VARCHAR(50),  -- Unique identifier for the case
    AGENT                  VARCHAR(100), -- Name of the agent handling the case
    AGENT_MANAGER          VARCHAR(100), -- Manager of the agent
    ACTUAL_ESCALATED_AT    TIMESTAMP,    -- Original escalation timestamp of the case
    ADJUSTED_ESCALATED_AT  TIMESTAMP,    -- Escalation timestamp adjusted according to business rules
    ESCALATED_OUTSIDE_WORKING_HOURS_FLG BOOLEAN, -- Flag indicating if escalation occurred outside working hours
    ESCALATED_WEEKEND_FLG  BOOLEAN,      -- Flag indicating if escalation occurred on a weekend
    FRT_AT                 TIMESTAMP,    -- Timestamp of the first response to the case
    FRT_SEC                INTEGER,      -- First response time in seconds (from adjusted escalation time)
    FRT_SLA_MET_FLG        BOOLEAN,      -- Flag indicating if first response met SLA (≤ 6 hours)
    FRT_IN_SCHEDULE_FLG    BOOLEAN       -- Flag indicating if the first response was within the agent's scheduled work hours
    ELT_INSERT_TIMESTAMP   TIMESTAMP     -- When the row was inserted
)
    comment = 'Table containing case metrics with adjusted escalations and SLA flags for SumUps elite customer support'
;
