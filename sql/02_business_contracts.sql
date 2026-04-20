CREATE OR REPLACE VIEW main.campaign_app.vw_campaign_current_definition AS
SELECT
  h.campaign_id,
  h.campaign_name,
  h.status,
  h.start_date,
  h.end_date,
  h.current_version,
  b.challenge,
  b.target_business_outcome,
  s.universe_view,
  a.activation_object_name,
  a.effective_start_date,
  a.effective_end_date
FROM main.campaign_app.campaign_header h
LEFT JOIN main.campaign_app.campaign_briefing_version b
  ON h.campaign_id = b.campaign_id AND h.current_version = b.version_id
LEFT JOIN main.campaign_app.campaign_segmentation_version s
  ON h.campaign_id = s.campaign_id AND h.current_version = s.version_id
LEFT JOIN main.campaign_app.campaign_activation_version a
  ON h.campaign_id = a.campaign_id AND h.current_version = a.version_id;
