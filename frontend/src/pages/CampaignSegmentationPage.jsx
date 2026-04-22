import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import Layout from "../components/Layout";
import RuleGroupCard from "../components/RuleGroupCard";
import SegmentationSummary from "../components/SegmentationSummary";
import AudiencePreviewCard from "../components/AudiencePreviewCard";
import Toast from "../components/Toast";
import { useToast } from "../hooks/useToast";
import { api } from "../api/client";

export default function CampaignSegmentationPage() {
  const { campaignId } = useParams();
  const { toast, show } = useToast();
  const [catalog, setCatalog] = useState(null);
  const [campaign, setCampaign] = useState(null);
  const [initialAudienceCode, setInitialAudienceCode] = useState("prime");
  const [nativeRules, setNativeRules] = useState([]);
  const [includeRules, setIncludeRules] = useState([]);
  const [excludeRules, setExcludeRules] = useState([]);
  const [preview, setPreview] = useState(null);

  useEffect(() => {
    Promise.all([
      api.get("/api/catalog/full"),
      api.get(`/api/campaigns/${campaignId}`),
    ])
      .then(([catalogData, campaignData]) => {
        setCatalog(catalogData);
        setCampaign(campaignData);
        if (campaignData.initial_audience_code) setInitialAudienceCode(campaignData.initial_audience_code);
        setNativeRules(campaignData.native_rules || []);
        setIncludeRules(campaignData.include_rules || []);
        setExcludeRules(campaignData.exclude_rules || []);
        if (campaignData.estimated_count) {
          setPreview({
            estimated_count: campaignData.estimated_count,
            sql_preview: campaignData.generated_sql || "",
          });
        }
      })
      .catch((error) => show(error.message, "error"));
  }, [campaignId]);

  const nativeFields = useMemo(() => {
    if (!catalog) return [];
    return Object.entries(catalog.native_fields).map(([value, meta]) => ({ value, label: meta.label }));
  }, [catalog]);

  const themes = useMemo(() => {
    if (!catalog) return [];
    return Object.entries(catalog.themes).map(([value, meta]) => ({ value, label: meta.label }));
  }, [catalog]);

  const thematicFields = useMemo(() => {
    if (!catalog) return [];
    const merged = [];
    Object.entries(catalog.themes).forEach(([themeCode, themeMeta]) => {
      Object.entries(themeMeta.fields).forEach(([fieldCode, fieldMeta]) => {
        merged.push({ value: fieldCode, label: `${themeMeta.label} - ${fieldMeta.label}`, themeCode });
      });
    });
    return merged;
  }, [catalog]);

  if (!catalog || !campaign) {
    return <Layout title="Segmentação"><div className="card">Carregando...</div></Layout>;
  }

  const selectedAudience = catalog.initial_audiences.find((item) => item.code === initialAudienceCode);

  async function handlePreview() {
    try {
      const result = await api.post(`/api/campaigns/${campaignId}/segmentation/preview`, {
        initial_audience_code: initialAudienceCode,
        initial_audience_view: selectedAudience?.source_view,
        native_rules: nativeRules,
        include_rules: includeRules,
        exclude_rules: excludeRules,
      });
      setPreview(result);
      show("Preview atualizado");
    } catch (error) {
      show(error.message, "error");
    }
  }

  async function handleSave() {
    try {
      const result = await api.put(`/api/campaigns/${campaignId}/segmentation`, {
        initial_audience_code: initialAudienceCode,
        initial_audience_view: selectedAudience?.source_view,
        native_rules: nativeRules,
        include_rules: includeRules,
        exclude_rules: excludeRules,
      });
      setPreview(result);
      show("Segmentação salva com sucesso");
    } catch (error) {
      show(error.message, "error");
    }
  }

  return (
    <Layout title={`Segmentação - ${campaign.campaign_name}`}>
      <Toast toast={toast} />
      <div className="card">
        <h3>Público inicial</h3>
        <select value={initialAudienceCode} onChange={(e) => setInitialAudienceCode(e.target.value)}>
          {catalog.initial_audiences.map((audience) => (
            <option key={audience.code} value={audience.code}>
              {audience.label}
            </option>
          ))}
        </select>
        <p className="muted">{selectedAudience?.description}</p>
      </div>

      <RuleGroupCard title="Filtros nativos" rules={nativeRules} setRules={setNativeRules} fields={nativeFields} themes={[]} />
      <RuleGroupCard title="Inclusões temáticas" rules={includeRules} setRules={setIncludeRules} fields={thematicFields} themes={themes} withTheme />
      <RuleGroupCard title="Exclusões temáticas" rules={excludeRules} setRules={setExcludeRules} fields={thematicFields} themes={themes} withTheme />

      <SegmentationSummary
        segmentation={{
          initial_audience_code: initialAudienceCode,
          native_rules: nativeRules,
          include_rules: includeRules,
          exclude_rules: excludeRules,
          estimated_count: preview?.estimated_count,
        }}
      />
      <AudiencePreviewCard preview={preview} />

      <div className="toolbar">
        <button className="btn btn-secondary" onClick={handlePreview}>Atualizar estimativa</button>
        <button className="btn" onClick={handleSave}>Salvar segmentação</button>
        <Link className="btn" to={`/campaigns/${campaignId}/activation`}>Ir para ativação</Link>
      </div>
    </Layout>
  );
}
