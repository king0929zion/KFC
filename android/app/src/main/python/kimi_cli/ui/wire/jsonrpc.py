from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field
try:
    from pydantic import ConfigDict, TypeAdapter
except Exception:
    class ConfigDict(dict):
        def __init__(self, *args, **kwargs):
            super().__init__()
    class TypeAdapter:  # minimal stub for v1
        def __init__(self, *_args, **_kwargs):
            pass

JSONRPC_VERSION = "2.0"


class _MessageBase(BaseModel):
    jsonrpc: Literal["2.0"]

    model_config = ConfigDict(extra="forbid")


class JSONRPCRequest(_MessageBase):
    method: str
    id: str | None = None
    params: dict[str, Any] = Field(default_factory=dict)


class _ResponseBase(_MessageBase):
    id: str | None


class JSONRPCSuccessResponse(_ResponseBase):
    result: dict[str, Any]


class JSONRPCErrorObject(BaseModel):
    code: int
    message: str
    data: Any | None = None


class JSONRPCErrorResponse(_ResponseBase):
    error: JSONRPCErrorObject


JSONRPCMessage = JSONRPCRequest | JSONRPCSuccessResponse | JSONRPCErrorResponse
JSONRPC_MESSAGE_ADAPTER = TypeAdapter(JSONRPCMessage) if 'TypeAdapter' in globals() else None

__all__ = [
    "JSONRPCRequest",
    "JSONRPCSuccessResponse",
    "JSONRPCErrorObject",
    "JSONRPCErrorResponse",
    "JSONRPCMessage",
    "JSONRPC_MESSAGE_ADAPTER",
]
