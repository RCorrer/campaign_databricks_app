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
    start_date: str | None = None
    end_date: str | None = None
    periodicity: Literal['DIARIA', 'SEMANAL', 'MENSAL', 'PONTUAL']
    max_impacts_month: int = 1
    control_group_enabled: bool = True
    description: str | None = None




class CampaignUpdate(BaseModel):
    name: str
    objective: str
    theme: str
    strategy: str
    start_date: str | None = None
    end_date: str | None = None
    periodicity: Literal['DIARIA', 'SEMANAL', 'MENSAL', 'PONTUAL'] = 'MENSAL'
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
    field: str
    operator: str
    value: Any
    logical_connector: Literal['AND', 'OR'] = 'AND'
    theme: str | None = None
    entity: str | None = None
    source_scope: Literal['NATIVE', 'THEMATIC'] = 'NATIVE'


class RuleGroup(BaseModel):
    name: str
    conditions: list[RuleCondition] = Field(default_factory=list)


class SegmentationPayload(BaseModel):
    initial_audience_code: str
    universe_view: str
    native_include_groups: list[RuleGroup] = Field(default_factory=list)
    native_exclude_groups: list[RuleGroup] = Field(default_factory=list)
    include_groups: list[RuleGroup] = Field(default_factory=list)
    exclude_groups: list[RuleGroup] = Field(default_factory=list)
    save_as_version_note: str | None = None


class StatusChangePayload(BaseModel):
    new_status: CampaignStatus
    reason: str | None = None


class ActivationPayload(BaseModel):
    materialization_mode: Literal['TABLE', 'VIEW'] = 'TABLE'
    execution_mode: Literal['RUN'] = 'RUN'
    effective_start_date: str | None = None
    effective_end_date: str | None = None


class CampaignSummary(BaseModel):
    campaign_id: str
    name: str
    status: CampaignStatus
    start_date: str | None = None
    end_date: str | None = None
    version: int
