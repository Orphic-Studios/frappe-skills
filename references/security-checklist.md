# Frappe & ERPNext Security Checklist

Use this checklist before shipping any server script, whitelisted API endpoint, or custom app to production.

## 1. SQL & Database Safety
- [ ] Zero raw string interpolation (`f"..."`, `.format()`, `%`) inside `frappe.db.sql()`.
- [ ] All SQL parameters use dictionary placeholders (`%(param)s`) or `frappe.qb` (PyPika Query Builder).
- [ ] `frappe.get_list()` is used instead of `frappe.get_all()` whenever user-level Role & User Permissions must be enforced.

## 2. Whitelisted Endpoints (`@frappe.whitelist()`)
- [ ] Every `@frappe.whitelist()` function explicitly checks permissions via `frappe.has_permission(doctype, ptype, throw=True)` or `doc.check_permission(ptype)`.
- [ ] `allow_guest=True` is only used on public endpoints with strict input validation and rate limiting (`@frappe.rate_limit(limit=..., seconds=...)`).
- [ ] Internal helper functions are **not** decorated with `@frappe.whitelist()`.

## 3. Secrets & Configuration
- [ ] API keys, tokens, and external passwords use the `Password` fieldtype (encrypted at rest via `frappe.utils.password.get_decrypted_password`) or `site_config.json` — never hardcoded in Python/JS or committed to Git.
- [ ] Sensitive uploaded files are saved with `is_private = 1` (`/private/files/`).

## 4. Portal & Web Views
- [ ] User-generated HTML rendered in Jinja templates or Print Formats is sanitized (`frappe.utils.sanitize_html`).
- [ ] CSRF protection remains enabled (`ignore_csrf` is not set in production).
