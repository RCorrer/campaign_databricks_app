CREATE OR REPLACE VIEW main.campaign_app.vw_campaign_current_definition AS
SELECT
  header.campaign_id,
  header.campaign_name,
  header.theme,
  header.objective,
  header.strategy,
  header.status,
  header.periodicity,
  header.start_date,
  header.end_date,
  header.max_impacts_month,
  header.control_group_enabled,
  header.current_version,
  briefing.challenge,
  briefing.target_business_outcome,
  briefing.channels,
  briefing.constraints,
  briefing.business_rules,
  briefing.notes,
  segmentation.initial_audience_code,
  segmentation.universe_view,
  segmentation.native_include_rules_json,
  segmentation.native_exclude_rules_json,
  segmentation.include_rules_json,
  segmentation.exclude_rules_json,
  segmentation.preview_sql,
  segmentation.estimated_audience,
  activation.materialization_mode,
  activation.activation_object_name,
  activation.activation_sql,
  activation.effective_start_date,
  activation.effective_end_date,
  activation.activation_status
FROM main.campaign_app.campaign_header header
LEFT JOIN main.campaign_app.campaign_briefing_version briefing
  ON header.campaign_id = briefing.campaign_id
 AND header.current_version = briefing.version_id
LEFT JOIN main.campaign_app.campaign_segmentation_version segmentation
  ON header.campaign_id = segmentation.campaign_id
 AND header.current_version = segmentation.version_id
LEFT JOIN main.campaign_app.campaign_activation_version activation
  ON header.campaign_id = activation.campaign_id
 AND header.current_version = activation.version_id;
