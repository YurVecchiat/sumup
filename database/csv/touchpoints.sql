create or replace TABLE SUMUP.CSV.TOUCHPOINTS (
	CASE_ID VARCHAR(16777216), --  Unique identifier for the customer support case
	TP_ID VARCHAR(16777216), -- A unique identifier for the touchpoint (i.e. the interaction between the customer and the support team).
	CHANNEL VARCHAR(16777216), -- The communication channel used by the customer to contact us
	AGENT VARCHAR(16777216), -- The name of the customer support agent.
	AGENT_MANAGER VARCHAR(16777216), -- The name of the manager who oversees the agent.
	AGENT_COUNTRY VARCHAR(16777216), -- The location of the agent
	TP_REASON VARCHAR(16777216), -- The general reason for the customer's contact.
	TP_REASON_DETAIL VARCHAR(16777216) -- A more specific description of the reason for the customer'scontact.
)
	comment = 'Table containing information about the productive hours worked by SumUp's customer support agents.'
  ;
