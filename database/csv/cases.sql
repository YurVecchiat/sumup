create or replace TABLE SUMUP.CSV.CASES (
	CASE_ID VARCHAR(16777216), -- A unique identifier for the customer support case.
	AGENT VARCHAR(16777216), -- The name of the customer support agent.
	MANAGER VARCHAR(16777216), -- The name of the manager who oversees the agent.
	ESCALATED_AT TIMESTAMP_NTZ(9), -- The date and time when the case was escalated to the elite squad
team.
	FIRST_REPLY_AT TIMESTAMP_NTZ(9) -- The date and time when the elite squad team first replied to the case
)
	comment = 'Table containing information about cases that were escalated to SumUps elite squad team.'
;
