from datetime import datetime
from uuid import uuid4

from backend.core.config import settings
from backend.models.contracts import (
    ActivationPayload,
    BriefingPayload,
    CampaignCreate,
    CampaignSummary,
    SegmentationPayload,
    StatusChangePayload,
)
from backend.services.query_builder import QueryBuilderService
from backend.utils.mapping_loader import load_semantic_mapping


STATUS_LABELS = {
    'PREPARACAO': 'Preparação',
    'SEGMENTACAO': 'Segmentação',
    'ATIVACAO': 'Ativação',
    'ATIVO': 'Ativo',
    'PAUSADO': 'Pausado',
    'CONCLUIDO': 'Concluído',
    'ENCERRADO': 'Encerrado',
    'CANCELADO': 'Cancelado',
}


class CampaignService:
    def __init__(self):
        self.query_builder = QueryBuilderService()
        self._store: dict[str, dict] = {}

    def seed_demo_data(self) -> list[dict]:
        if self._store:
            return self.list_campaigns()

        mapping = load_semantic_mapping(settings.campaign_mapping_file)
        audiences = mapping.get('initial_audiences', [])

        first = self.create_campaign(CampaignCreate(
            name='Aquisição Cartão Prime sem Black',
            objective='Ofertar upgrade de cartão para clientes Prime com alta renda e sem cartão Black.',
            theme='CARTOES',
            strategy='Aquisição',
            start_date='2026-05-01',
            end_date='2026-05-31',
            periodicity='MENSAL',
            max_impacts_month=2,
            control_group_enabled=True,
            description='Campanha de CRM com público inicial Prime, filtro nativo e cruzamento com tema Cartões.'
        ))
        self.save_briefing(first.campaign_id, BriefingPayload(
            challenge='Encontrar clientes Prime com boa capacidade financeira e sem cartão premium no portfólio.',
            target_business_outcome='Aumentar emissão do cartão premium em 15%.',
            channels=['Push', 'Email', 'App Inbox'],
            constraints=['Respeitar consentimento de marketing', 'Não impactar clientes com restrição bureau'],
            business_rules=['Usar público inicial Prime', 'Aplicar filtros nativos de renda e UF', 'Excluir clientes com cartão Black'],
            notes='Fluxo inspirado em Data Cloud para CRM no-code.'
        ))
        self.save_segmentation(first.campaign_id, SegmentationPayload(
            initial_audience_code='prime',
            universe_view=_find_audience_view(audiences, 'prime'),
            native_include_groups=[{
                'name': 'Base Prime com alta renda',
                'conditions': [
                    {'field': 'monthly_income', 'operator': 'GT', 'value': 12000, 'source_scope': 'NATIVE'},
                    {'field': 'state', 'operator': 'IN', 'value': ['SP', 'PR', 'RJ'], 'logical_connector': 'AND', 'source_scope': 'NATIVE'}
                ]
            }],
            native_exclude_groups=[{
                'name': 'Sem bloqueio de comunicação',
                'conditions': [
                    {'field': 'marketing_consent', 'operator': 'EQUALS', 'value': False, 'source_scope': 'NATIVE'}
                ]
            }],
            include_groups=[{
                'name': 'Elegíveis ao cartão premium',
                'conditions': [
                    {'theme': 'elegibilidade', 'entity': 'main.customer_360.tb_elegibilidade_ofertas', 'field': 'produto', 'operator': 'EQUALS', 'value': 'CARTAO_BLACK', 'source_scope': 'THEMATIC'},
                    {'theme': 'elegibilidade', 'entity': 'main.customer_360.tb_elegibilidade_ofertas', 'field': 'elegivel', 'operator': 'EQUALS', 'value': True, 'logical_connector': 'AND', 'source_scope': 'THEMATIC'}
                ]
            }],
            exclude_groups=[{
                'name': 'Excluir quem já possui Black',
                'conditions': [
                    {'theme': 'cartoes', 'entity': 'main.customer_360.tb_cartoes', 'field': 'card_product', 'operator': 'EQUALS', 'value': 'BLACK', 'source_scope': 'THEMATIC'}
                ]
            }, {
                'name': 'Excluir restrição bureau',
                'conditions': [
                    {'theme': 'credito', 'entity': 'main.customer_360.tb_credito_perfil', 'field': 'restricao_bureau', 'operator': 'EQUALS', 'value': True, 'source_scope': 'THEMATIC'}
                ]
            }],
            save_as_version_note='Prime v1'
        ))
        self.activate(first.campaign_id, ActivationPayload(
            materialization_mode='TABLE',
            execution_mode='RUN',
            effective_start_date='2026-05-01',
            effective_end_date='2026-05-31'
        ))

        second = self.create_campaign(CampaignCreate(
            name='Capital de Giro PJ Paraná',
            objective='Ativar ofertas PJ para empresas do Paraná com elegibilidade e risco controlado.',
            theme='CREDITO',
            strategy='Expansão',
            start_date='2026-06-01',
            end_date='2026-06-30',
            periodicity='MENSAL',
            max_impacts_month=1,
            control_group_enabled=False,
            description='Exemplo de campanha PJ com público inicial e cruzamentos temáticos.'
        ))
        self.save_briefing(second.campaign_id, BriefingPayload(
            challenge='Encontrar empresas com limite aprovado e sem atraso relevante.',
            target_business_outcome='Incrementar contratação de capital de giro.',
            channels=['Gerente', 'Email'],
            constraints=['Atender apenas PJ do Paraná'],
            business_rules=['Público inicial PJ', 'Usar elegibilidade e crédito como temas de cruzamento'],
            notes='Aguardando ativação.'
        ))
        self.save_segmentation(second.campaign_id, SegmentationPayload(
            initial_audience_code='pj',
            universe_view=_find_audience_view(audiences, 'pj'),
            native_include_groups=[{
                'name': 'Empresas do Paraná',
                'conditions': [
                    {'field': 'state', 'operator': 'EQUALS', 'value': 'PR', 'source_scope': 'NATIVE'}
                ]
            }],
            include_groups=[{
                'name': 'Elegíveis a capital de giro',
                'conditions': [
                    {'theme': 'elegibilidade', 'entity': 'main.customer_360.tb_elegibilidade_ofertas', 'field': 'produto', 'operator': 'EQUALS', 'value': 'CAPITAL_GIRO', 'source_scope': 'THEMATIC'},
                    {'theme': 'elegibilidade', 'entity': 'main.customer_360.tb_elegibilidade_ofertas', 'field': 'elegivel', 'operator': 'EQUALS', 'value': True, 'logical_connector': 'AND', 'source_scope': 'THEMATIC'}
                ]
            }],
            exclude_groups=[{
                'name': 'Excluir atraso alto',
                'conditions': [
                    {'theme': 'credito', 'entity': 'main.customer_360.tb_credito_perfil', 'field': 'atraso_max_dias_12m', 'operator': 'GT', 'value': 10, 'source_scope': 'THEMATIC'}
                ]
            }],
            save_as_version_note='PJ PR v1'
        ))

        third = self.create_campaign(CampaignCreate(
            name='Investimentos Exclusive Digital',
            objective='Ofertar investimentos premium para clientes Exclusive com forte uso digital.',
            theme='INVESTIMENTOS',
            strategy='Relacionamento',
            start_date='2026-07-01',
            end_date='2026-07-31',
            periodicity='MENSAL',
            max_impacts_month=1,
            control_group_enabled=True,
            description='Campanha em etapa de segmentação.'
        ))
        self.save_briefing(third.campaign_id, BriefingPayload(
            challenge='Combinar público Exclusive com alta liquidez e adesão digital.',
            target_business_outcome='Aumentar captação em investimento premium.',
            channels=['Email', 'WhatsApp'],
            constraints=['Excluir clientes sem app ativo'],
            business_rules=['Usar público inicial Exclusive', 'Cruzar com investimentos e canais digitais'],
            notes='Em revisão comercial.'
        ))
        self.save_segmentation(third.campaign_id, SegmentationPayload(
            initial_audience_code='exclusive',
            universe_view=_find_audience_view(audiences, 'exclusive'),
            native_include_groups=[{
                'name': 'Exclusive com renda mínima',
                'conditions': [
                    {'field': 'monthly_income', 'operator': 'GT', 'value': 20000, 'source_scope': 'NATIVE'}
                ]
            }],
            include_groups=[{
                'name': 'Possui investimento alto',
                'conditions': [
                    {'theme': 'investimentos', 'entity': 'main.customer_360.tb_investimentos', 'field': 'total_invested', 'operator': 'GT', 'value': 100000, 'source_scope': 'THEMATIC'}
                ]
            }, {
                'name': 'Cliente digital',
                'conditions': [
                    {'theme': 'canais_digitais', 'entity': 'main.customer_360.tb_canais_digitais', 'field': 'mobile_app_active', 'operator': 'EQUALS', 'value': True, 'source_scope': 'THEMATIC'},
                    {'theme': 'canais_digitais', 'entity': 'main.customer_360.tb_canais_digitais', 'field': 'login_count_30d', 'operator': 'GT', 'value': 10, 'logical_connector': 'AND', 'source_scope': 'THEMATIC'}
                ]
            }],
            exclude_groups=[],
            save_as_version_note='Exclusive digital v1'
        ))
        self.change_status(third.campaign_id, StatusChangePayload(new_status='PAUSADO', reason='Ajuste de copy e régua.'))
        return self.list_campaigns()

    def create_campaign(self, payload: CampaignCreate) -> CampaignSummary:
        campaign_id = f"CMP-{uuid4().hex[:10].upper()}"
        mapping = load_semantic_mapping(settings.campaign_mapping_file)
        base = {
            'campaign_id': campaign_id,
            'name': payload.name,
            'theme': payload.theme,
            'objective': payload.objective,
            'strategy': payload.strategy,
            'status': 'PREPARACAO',
            'status_label': STATUS_LABELS['PREPARACAO'],
            'version': 1,
            'created_at': datetime.utcnow().isoformat(),
            'start_date': payload.start_date,
            'end_date': payload.end_date,
            'campaign': payload.model_dump(),
            'briefing': None,
            'segmentation': None,
            'activation': None,
            'builder_catalog': mapping,
            'timeline': [{'event': 'CAMPAIGN_CREATED', 'status': 'PREPARACAO', 'timestamp': datetime.utcnow().isoformat()}],
        }
        self._store[campaign_id] = base
        return CampaignSummary(campaign_id=campaign_id, name=payload.name, status='PREPARACAO', start_date=payload.start_date, end_date=payload.end_date, version=1)

    def list_campaigns(self) -> list[dict]:
        return list(self._store.values())

    def get_campaign(self, campaign_id: str) -> dict:
        return self._store[campaign_id]

    def save_briefing(self, campaign_id: str, payload: BriefingPayload) -> dict:
        campaign = self._store[campaign_id]
        campaign['briefing'] = payload.model_dump()
        campaign['status'] = 'SEGMENTACAO'
        campaign['status_label'] = STATUS_LABELS['SEGMENTACAO']
        campaign['version'] += 1
        campaign['timeline'].append({'event': 'BRIEFING_REFINED', 'status': 'SEGMENTACAO', 'timestamp': datetime.utcnow().isoformat()})
        return campaign

    def save_segmentation(self, campaign_id: str, payload: SegmentationPayload) -> dict:
        campaign = self._store[campaign_id]
        preview_sql = self.query_builder.build_preview_sql(payload)
        campaign['segmentation'] = {**payload.model_dump(), 'preview_sql': preview_sql}
        campaign['status'] = 'ATIVACAO'
        campaign['status_label'] = STATUS_LABELS['ATIVACAO']
        campaign['version'] += 1
        campaign['timeline'].append({'event': 'SEGMENTATION_SAVED', 'status': 'ATIVACAO', 'timestamp': datetime.utcnow().isoformat()})
        return campaign

    def activate(self, campaign_id: str, payload: ActivationPayload) -> dict:
        campaign = self._store[campaign_id]
        activation_object_name = f"{settings.execution_namespace}.campaign_audience_{campaign_id.lower().replace('-', '_')}"
        snapshot_object_name = f"{settings.execution_namespace}.campaign_audience_snapshot_{campaign_id.lower().replace('-', '_')}"
        campaign['activation'] = {
            **payload.model_dump(),
            'activation_object_name': activation_object_name,
            'snapshot_object_name': snapshot_object_name,
            'activation_sql': self._build_activation_sql(campaign_id, campaign, payload, activation_object_name, snapshot_object_name),
        }
        campaign['status'] = 'ATIVO' if payload.execution_mode == 'RUN' else 'ATIVACAO'
        campaign['status_label'] = STATUS_LABELS[campaign['status']]
        campaign['version'] += 1
        campaign['timeline'].append({'event': 'CAMPAIGN_ACTIVATED', 'status': campaign['status'], 'timestamp': datetime.utcnow().isoformat()})
        return campaign

    def change_status(self, campaign_id: str, payload: StatusChangePayload) -> dict:
        campaign = self._store[campaign_id]
        campaign['status'] = payload.new_status
        campaign['status_label'] = STATUS_LABELS[payload.new_status]
        campaign['timeline'].append({'event': 'STATUS_CHANGED', 'status': payload.new_status, 'reason': payload.reason, 'timestamp': datetime.utcnow().isoformat()})
        return campaign

    def _build_activation_sql(self, campaign_id: str, campaign: dict, payload: ActivationPayload, activation_object_name: str, snapshot_object_name: str) -> str:
        segmentation_sql = (campaign.get('segmentation') or {}).get('preview_sql', f"SELECT cpf_cnpj FROM {settings.source_namespace}.vw_publico_varejo")
        ddl = {
            'TABLE': 'CREATE OR REPLACE TABLE',
            'VIEW': 'CREATE OR REPLACE VIEW',
            'MATERIALIZED_VIEW': 'CREATE OR REPLACE MATERIALIZED VIEW',
        }[payload.materialization_mode]
        return f"""
{ddl} {activation_object_name}
USING DELTA
AS
SELECT
    '{campaign_id}' AS campaign_id,
    {campaign['version']} AS segmentation_version,
    cpf_cnpj,
    current_timestamp() AS dt_segmentacao,
    DATE('{payload.effective_start_date}') AS dt_inicio_vigencia,
    DATE('{payload.effective_end_date}') AS dt_fim_vigencia,
    'ATIVO' AS status_audiencia
FROM (
    {segmentation_sql}
);

INSERT INTO {settings.execution_namespace}.campaign_run_log
SELECT
    '{campaign_id}' AS campaign_id,
    {campaign['version']} AS segmentation_version,
    current_timestamp() AS run_ts,
    '{payload.execution_mode}' AS execution_mode,
    '{payload.materialization_mode}' AS materialization_mode,
    '{activation_object_name}' AS output_object,
    NULL AS total_records,
    '{snapshot_object_name}' AS snapshot_object,
    'SUCCESS' AS run_status,
    NULL AS error_message;
""".strip()


def _find_audience_view(audiences: list[dict], audience_code: str) -> str:
    for audience in audiences:
        if audience.get('code') == audience_code:
            return audience['source_view']
    raise ValueError(f'Público inicial não encontrado: {audience_code}')


campaign_service = CampaignService()
