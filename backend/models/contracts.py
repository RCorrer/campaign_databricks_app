from typing import Any, Literal

from pydantic import BaseModel, Field


class CampaignCreateRequest(BaseModel):
    name: str
    theme: str
    objective: str
    strategy: str
    description: str | None = None
    primary_channel: str
    priority: str
    owner_team: str | None = None
    goal_kpi: str | None = None
    goal_value: float | None = None
    start_date: str
    end_date: str
    periodicity: str = "MENSAL"
    max_impacts_month: int = 1
    control_group_enabled: bool = False


class CampaignUpdateRequest(CampaignCreateRequest):
    status_reason: str | None = None


class CampaignBriefingRequest(BaseModel):
    challenge: str
    target_business_outcome: str
    channels: list[str] = Field(default_factory=list)
    constraints: str | None = None
    business_rules: str | None = None
    notes: str | None = None


class NativeRule(BaseModel):
    field: str
    operator: str
    value: Any


class ThematicRule(BaseModel):
    theme: str
    field: str
    operator: str
    value: Any


class SegmentationSaveRequest(BaseModel):
    initial_audience_code: str
    initial_audience_view: str
    native_rules: list[NativeRule] = Field(default_factory=list)
    include_rules: list[ThematicRule] = Field(default_factory=list)
    exclude_rules: list[ThematicRule] = Field(default_factory=list)


class ActivationRequest(BaseModel):
    segmentation_version_no: int
    activation_mode: Literal["SNAPSHOT", "REFRESH"] = "SNAPSHOT"
    start_date: str
    end_date: str


class StatusChangeRequest(BaseModel):
    new_status: str
    reason: str | None = None
