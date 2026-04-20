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
        universes = mapping.get('universe_views', [])

        first = self.create_campaign(CampaignCreate(
            name='Campanha Crédito Consignado',
            objective='Aumentar contratação de crédito em clientes elegíveis.',
            theme='CRÉDITO',
            strategy='Ciclo de Vida',
            start_date='2026-05-01',
            end_date='2026-05-31',
            periodicity='MENSAL',
            max_impacts_month=2,
            control_group_enabled=True,
            description='Campanha principal de crédito.'
        ))
        self.save_briefing(first.campaign_id, BriefingPayload(
            challenge='Converter clientes já elegíveis com melhor propensão.',
            target_business_outcome='Elevar taxa de contratação em 12%.',
            channels=['Push', 'Email'],
            constraints=['Não impactar clientes com conta inativa'],
            business_rules=['Aplicar elegibilidade por produto', 'Respeitar frequência mensal'],
            notes='Briefing refinado com regras de elegibilidade e controle de impacto.'
        ))
        self.save_segmentation(first.campaign_id, SegmentationPayload(
            universe_view=universes[1] if len(universes) > 1 else universes[0],
            include_groups=[{
                'name': 'Elegíveis a crédito pessoal',
                'conditions': [{'topic': 'elegibilidade', 'entity': 'vw_elegibilidade_cliente', 'field': 'produto', 'operator': 'EQUALS', 'value': 'CREDITO_PESSOAL'}]
            }],
            exclude_groups=[{
                'name': 'Excluir conta inativa',
                'conditions': [{'topic': 'relacionamento', 'entity': 'vw_relacionamento_cliente', 'field': 'status_conta', 'operator': 'EQUALS', 'value': 'INATIVA'}]
            }],
            save_as_version_note='Versão inicial'
        ))
        self.activate(first.campaign_id, ActivationPayload(
            materialization_mode='TABLE',
            execution_mode='RUN',
            effective_start_date='2026-05-01',
            effective_end_date='2026-05-31'
        ))

        second = self.create_campaign(CampaignCreate(
            name='Campanha Investimentos Premium',
            objective='Direcionar ofertas de investimento para alta renda.',
            theme='INVESTIMENTO',
            strategy='Contexto',
            start_date='2026-06-01',
            end_date='2026-06-30',
            periodicity='MENSAL',
            max_impacts_month=1,
            control_group_enabled=False,
            description='Campanha em etapa de segmentação.'
        ))
        self.save_briefing(second.campaign_id, BriefingPayload(
            challenge='Encontrar clientes com alta liquidez e perfil premium.',
            target_business_outcome='Aumentar adesão a carteira administrada.',
            channels=['Email Marketing Personalizado', 'WhatsApp'],
            constraints=['Excluir clientes com comunicação bloqueada'],
            business_rules=['Priorizar segmento Exclusive e Prime'],
            notes='Segmentação será construída no-code.'
        ))
        self.save_segmentation(second.campaign_id, SegmentationPayload(
            universe_view=universes[-1],
            include_groups=[{
                'name': 'Segmento premium',
                'conditions': [{'topic': 'relacionamento', 'entity': 'vw_relacionamento_cliente', 'field': 'segmento', 'operator': 'IN', 'value': ['Prime', 'Exclusive']}]
            }],
            exclude_groups=[{
                'name': 'Excluir baixa propensão',
                'conditions': [{'topic': 'comportamento', 'entity': 'vw_comportamento_financeiro', 'field': 'propensao_investimento', 'operator': 'LT', 'value': 70}]
            }],
            save_as_version_note='Versão pronta para ativação'
        ))

        third = self.create_campaign(CampaignCreate(
            name='Campanha Reativação Cartões',
            objective='Retomar uso de cartões ativos com baixa transação.',
            theme='CARTÕES',
            strategy='Retenção',
            start_date='2026-04-01',
            end_date='2026-04-30',
            periodicity='MENSAL',
            max_impacts_month=3,
            control_group_enabled=True,
            description='Campanha pausada para ajuste de régua.'
        ))
        self.save_briefing(third.campaign_id, BriefingPayload(
            challenge='Aumentar ativação de cartões com incentivo tático.',
            target_business_outcome='Elevar volume transacional em 8%.',
            channels=['Push Personalizado', 'SMS'],
            constraints=['Não impactar clientes inadimplentes'],
            business_rules=['Controlar frequência por mês de referência'],
            notes='Operação temporariamente pausada.'
        ))
        self.change_status(third.campaign_id, StatusChangePayload(new_status='PAUSADO', reason='Ajuste na oferta criativa.'))
        return self.list_campaigns()

    def create_campaign(self, payload: CampaignCreate) -> CampaignSummary:
        campaign_id = f"CMP-{uuid4().hex[:10].upper()}"
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
            'available_universe_views': load_semantic_mapping(settings.campaign_mapping_file).get('universe_views', []),
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
        activation_object_name = f"{settings.metadata_namespace}.campaign_audience_{campaign_id.lower().replace('-', '_')}"
        campaign['activation'] = {
            **payload.model_dump(),
            'activation_object_name': activation_object_name,
            'activation_sql': self._build_activation_sql(campaign_id, campaign, payload, activation_object_name),
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

    def _build_activation_sql(self, campaign_id: str, campaign: dict, payload: ActivationPayload, activation_object_name: str) -> str:
        segmentation_sql = (campaign.get('segmentation') or {}).get('preview_sql', f"SELECT cpf_cnpj FROM {settings.source_namespace}.vw_universo_clientes_varejo")
        ddl = {
            'TABLE': 'CREATE OR REPLACE TABLE',
            'VIEW': 'CREATE OR REPLACE VIEW',
            'MATERIALIZED_VIEW': 'CREATE OR REPLACE MATERIALIZED VIEW',
        }[payload.materialization_mode]
        return f"""
{ddl} {activation_object_name}
AS
SELECT
    '{campaign_id}' AS campaign_id,
    cpf_cnpj,
    current_timestamp() AS segmentation_ts,
    DATE('{payload.effective_start_date}') AS activation_start_date,
    DATE('{payload.effective_end_date}') AS activation_end_date,
    {campaign['version']} AS rule_version
FROM (
    {segmentation_sql}
)
""".strip()


campaign_service = CampaignService()
