from typing import Any, Literal
from pydantic import BaseModel, Field


CampaignStatus = Literal[
    'PREPARACAO',
    'SEGMENTACAO',
    'ATIVACAO',
    'ATIVO',
    'PAUSADO',
    'CONCLUIDO',
    'ENCERRADO',
    'CANCELADO',
]


class CampaignCreate(BaseModel):
    name: str
    objective: str
    theme: str
    strategy: str
    start_date: str
    end_date: str
    periodicity: Literal['DIARIA', 'SEMANAL', 'MENSAL', 'PONTUAL']
    max_impacts_month: int = 1
    control_group_enabled: bool = True
    description: str | None = None


class BriefingPayload(BaseModel):
    challenge: str
    target_business_outcome: str
    channels: list[str] = Field(default_factory=list)
    constraints: list[str] = Field(default_factory=list)
    business_rules: list[str] = Field(default_factory=list)
    notes: str | None = None


class RuleCondition(BaseModel):
    topic: str
    entity: str
    field: str
    operator: str
    value: Any
    logical_connector: Literal['AND', 'OR'] = 'AND'


class RuleGroup(BaseModel):
    name: str
    conditions: list[RuleCondition] = Field(default_factory=list)


class SegmentationPayload(BaseModel):
    universe_view: str
    include_groups: list[RuleGroup] = Field(default_factory=list)
    exclude_groups: list[RuleGroup] = Field(default_factory=list)
    save_as_version_note: str | None = None


class StatusChangePayload(BaseModel):
    new_status: CampaignStatus
    reason: str | None = None


class ActivationPayload(BaseModel):
    materialization_mode: Literal['TABLE', 'VIEW', 'MATERIALIZED_VIEW'] = 'TABLE'
    execution_mode: Literal['PREVIEW', 'RUN'] = 'RUN'
    effective_start_date: str
    effective_end_date: str


class CampaignSummary(BaseModel):
    campaign_id: str
    name: str
    status: CampaignStatus
    start_date: str
    end_date: str
    version: int
