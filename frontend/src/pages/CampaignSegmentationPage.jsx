import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import Layout from "../components/Layout";
import RuleGroupCard from "../components/RuleGroupCard";
import SegmentationSummary from "../components/SegmentationSummary";
import AudiencePreviewCard from "../components/AudiencePreviewCard";
import Toast from "../components/Toast";
import { useToast } from "../hooks/useToast";
import { api } from "../api/client";

function buildInitialAudienceView(code) {
  return `main.campaign_sources.${code}`;
}

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
  const [saving, setSaving] = useState(false);
  const [previewing, setPreviewing] = useState(false);

  async function loadPage() {
    const [catalogData, campaignData] = await Promise.all([
      api.get("/api/catalog/full"),
      api.get(`/api/campaigns/${campaignId}`),
    ]);

    setCatalog(catalogData);
    setCampaign(campaignData);

    const currentAudience = (campaignData.initial_audience_code || "prime").toLowerCase();
    setInitialAudienceCode(currentAudience);
    setNativeRules(campaignData.native_rules || []);
    setIncludeRules(campaignData.include_rules || []);
    setExcludeRules(campaignData.exclude_rules || []);

    if (campaignData.generated_sql || campaignData.estimated_count) {
      setPreview({
        estimated_count: campaignData.estimated_count || 0,
        sql_preview: campaignData.generated_sql || "",
        version_no: campaignData.segmentation_version_no || null,
      });
    } else {
      setPreview(null);
    }
  }

  useEffect(() => {
    loadPage().catch((error) => show(error.message, "error"));
  }, [campaignId]);

  const nativeFields = useMemo(() => {
    if (!catalog) return [];
    return Object.entries(catalog.native_fields || {}).map(([value, meta]) => ({
      value,
      label: meta.label,
    }));
  }, [catalog]);

  const themes = useMemo(() => {
    if (!catalog) return [];
    return Object.entries(catalog.themes || {}).map(([value, meta]) => ({
      value,
      label: meta.label,
    }));
  }, [catalog]);

  const thematicFields = useMemo(() => {
    if (!catalog) return [];
    const merged = [];
    Object.entries(catalog.themes || {}).forEach(([themeCode, themeMeta]) => {
      Object.entries(themeMeta.fields || {}).forEach(([fieldCode, fieldMeta]) => {
        merged.push({
          value: fieldCode,
          label: `${themeMeta.label} - ${fieldMeta.label}`,
          themeCode,
        });
      });
    });
    return merged;
  }, [catalog]);

  function buildPayload() {
    const normalizedCode = initialAudienceCode.trim().toLowerCase();
    return {
      initial_audience_code: normalizedCode,
      initial_audience_view: buildInitialAudienceView(normalizedCode),
      native_rules: nativeRules,
      include_rules: includeRules,
      exclude_rules: excludeRules,
    };
  }

  async function handlePreview() {
    try {
      setPreviewing(true);
      const result = await api.post("/api/segmentation/preview", buildPayload());
      setPreview(result);
      show(`Prévia atualizada: ${result.estimated_count || 0} clientes`);
    } catch (error) {
      show(error.message, "error");
    } finally {
      setPreviewing(false);
    }
  }

  async function handleSave() {
    try {
      setSaving(true);
      const result = await api.put(`/api/campaigns/${campaignId}/segmentation`, buildPayload());
      setPreview(result);
      await loadPage();
      show(
        `Segmentação salva na versão ${result.version_no} com estimativa de ${result.estimated_count || 0} clientes`
      );
    } catch (error) {
      show(error.message, "error");
    } finally {
      setSaving(false);
    }
  }

  if (!catalog || !campaign) {
    return <div>Carregando...</div>;
  }

  return (
    <Layout>
      <Toast toast={toast} />

      <div className="page-header">
        <div>
          <h1>Segmentação da campanha</h1>
          <p>{campaign.campaign_name}</p>
        </div>
        <div className="page-actions">
          <Link className="btn btn-secondary" to={`/campaigns/${campaignId}/preparation`}>
            Voltar para preparation
          </Link>
          <Link className="btn" to={`/campaigns/${campaignId}/activation`}>
            Ir para activation
          </Link>
        </div>
      </div>

      <div className="card">
        <h3>Contexto atual</h3>
        <p>Status: {campaign.status}</p>
        <p>Versão atual de segmentação: {campaign.segmentation_version_no || "-"}</p>
        <p>Audiência inicial atual: {(campaign.initial_audience_code || initialAudienceCode).toLowerCase()}</p>
        <p>Estimativa atual: {campaign.estimated_count || 0}</p>
      </div>

      <div className="card">
        <h3>Público inicial</h3>
        <select value={initialAudienceCode} onChange={(e) => setInitialAudienceCode(e.target.value.toLowerCase())}>
          {Object.keys(catalog.audiences || {}).map((code) => (
            <option key={code} value={code.toLowerCase()}>
              {catalog.audiences[code].label}
            </option>
          ))}
        </select>
      </div>

      <RuleGroupCard
        title="Filtros nativos"
        rules={nativeRules}
        setRules={setNativeRules}
        fieldOptions={nativeFields}
        mode="native"
      />

      <RuleGroupCard
        title="Regras de inclusão"
        rules={includeRules}
        setRules={setIncludeRules}
        themeOptions={themes}
        fieldOptions={thematicFields}
        mode="thematic"
      />

      <RuleGroupCard
        title="Regras de exclusão"
        rules={excludeRules}
        setRules={setExcludeRules}
        themeOptions={themes}
        fieldOptions={thematicFields}
        mode="thematic"
      />

      <SegmentationSummary
        initialAudienceCode={initialAudienceCode}
        nativeRules={nativeRules}
        includeRules={includeRules}
        excludeRules={excludeRules}
      />

      <div className="form-actions">
        <button className="btn btn-secondary" onClick={handlePreview} disabled={previewing || saving}>
          {previewing ? "Gerando prévia..." : "Atualizar prévia"}
        </button>
        <button className="btn" onClick={handleSave} disabled={saving || previewing}>
          {saving ? "Salvando..." : "Salvar segmentação"}
        </button>
      </div>

      {preview && (
        <AudiencePreviewCard
          estimatedCount={preview.estimated_count || 0}
          sqlPreview={preview.sql_preview || ""}
        />
      )}
    </Layout>
  );
}
