"""Standardized API response helpers."""
from flask import jsonify


def success(data=None, message="Success", status=200):
    body = {"success": True, "message": message}
    if data is not None:
        body["data"] = data
    return jsonify(body), status


def error(message="An error occurred", status=400, errors=None):
    body = {"success": False, "error": message}
    if errors:
        body["errors"] = errors
    return jsonify(body), status


def paginate(query, page, per_page, serializer):
    """Helper to paginate a SQLAlchemy query."""
    pagination = query.paginate(page=page, per_page=per_page, error_out=False)
    return {
        "items":       [serializer(item) for item in pagination.items],
        "total":       pagination.total,
        "page":        pagination.page,
        "per_page":    pagination.per_page,
        "total_pages": pagination.pages,
        "has_next":    pagination.has_next,
        "has_prev":    pagination.has_prev,
    }
