CREATE OR REPLACE VIEW main.campaign_app.vw_campaign_current_definition AS
SELECT
  h.campaign_id,
  h.campaign_name,
  h.theme,
  h.objective,
  h.strategy,
  h.description,
  h.primary_channel,
  h.priority,
  h.owner_team,
  h.goal_kpi,
  h.goal_value,
  h.status,
  h.status_reason,
  h.periodicity,
  h.start_date,
  h.end_date,
  h.max_impacts_month,
  h.control_group_enabled,
  h.last_run_at,
  b.challenge,
  b.target_business_outcome,
  b.channels_json,
  b.constraints,
  b.business_rules,
  b.notes,
  s.version_no as segmentation_version_no,
  s.initial_audience_code,
  s.initial_audience_view,
  s.native_rules_json,
  s.include_rules_json,
  s.exclude_rules_json,
  s.native_rule_count,
  s.thematic_rule_count,
  s.generated_sql,
  s.estimated_count,
  a.version_no as activation_version_no,
  a.execution_target_name,
  a.activation_mode,
  a.start_date as activation_start_date,
  a.end_date as activation_end_date,
  a.activated_at,
  a.deactivated_at,
  h.updated_at,
  h.created_at
FROM main.campaign_app.campaign_header h
LEFT JOIN main.campaign_app.campaign_briefing_version b
  ON h.campaign_id = b.campaign_id AND b.is_current = TRUE
LEFT JOIN main.campaign_app.campaign_segmentation_version s
  ON h.campaign_id = s.campaign_id AND s.is_current = TRUE
LEFT JOIN main.campaign_app.campaign_activation_version a
  ON h.campaign_id = a.campaign_id AND a.is_current = TRUE;

CREATE OR REPLACE VIEW main.campaign_app.vw_campaign_dashboard AS
SELECT
  h.campaign_id,
  h.campaign_name,
  h.theme,
  h.status,
  h.primary_channel,
  h.priority,
  h.owner_team,
  h.start_date,
  h.end_date,
  COALESCE(s.native_rule_count, 0) as native_rule_count,
  COALESCE(s.thematic_rule_count, 0) as thematic_rule_count,
  h.last_run_at,
  h.updated_at,
  h.created_at
FROM main.campaign_app.campaign_header h
LEFT JOIN main.campaign_app.campaign_segmentation_version s
  ON h.campaign_id = s.campaign_id AND s.is_current = TRUE;
