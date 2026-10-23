# ERPNext — HR, Payroll & Projects

This file covers the HR/Payroll module and the Projects module in ERPNext. Frappe HR is also available as a standalone app (see `../apps/ecosystem.md`); when bundled in ERPNext, the same DocTypes apply.

## Table of Contents

1. [HR Module Overview](#hr-module-overview)
2. [Employee Master](#employee-master)
3. [Attendance](#attendance)
4. [Leave Management](#leave-management)
5. [Payroll](#payroll)
6. [Expense Claim](#expense-claim)
7. [Recruitment](#recruitment)
8. [Appraisal](#appraisal)
9. [Shift Management](#shift-management)
10. [Employee Lifecycle](#employee-lifecycle)
11. [Projects Module](#projects-module)
12. [Timesheets](#timesheets)
13. [Issues](#issues)
14. [Common Errors](#common-errors)

## HR Module Overview

The HR module covers the full employee lifecycle from recruitment to separation:

- **Recruitment** → Job Opening, Job Applicant, Job Offer
- **Onboarding** → Employee Onboarding template + Employee record
- **Daily ops** → Attendance, Leave Application, Expense Claim, Shift Assignment
- **Monthly** → Payroll Entry, Salary Slip
- **Annual** → Appraisal, Leave Allocation
- **Offboarding** → Employee Separation, Full & Final Settlement

Key DocTypes:
- `Employee` — master record
- `Department`, `Designation`, `Branch` — organizational hierarchy
- `Attendance` — daily attendance
- `Leave Application`, `Leave Allocation`, `Leave Policy` — leave management
- `Salary Structure`, `Salary Slip`, `Payroll Entry` — payroll
- `Expense Claim` — employee reimbursements
- `Appraisal` — performance reviews

## Employee Master

The `Employee` DocType is the central HR record.

### Key fields

| Field | Description |
|---|---|
| `employee` | Auto-generated employee number (e.g. `EMP-0001`) |
| `first_name`, `middle_name`, `last_name` | Name components |
| `employee_name` | Auto-concatenated full name |
| `company` | Which company they belong to |
| `status` | Active / Inactive / Left |
| `gender` | Male / Female / Other / Not Specified |
| `date_of_birth` | DOB |
| `date_of_joining` | DOJ |
| `relieving_date` | When they left (set when status=Left) |
| `department` | Link to Department |
| `designation` | Link to Designation |
| `branch` | Link to Branch |
| `employment_type` | Full-time / Part-time / Contract / Intern / Probation |
| `grade` | Link to Employee Grade (for default salary) |
| `reports_to` | Link to another Employee (manager) |
| `user_id` | Link to User (for Desk login) |
| `prefered_email` | Email used for HR communications |
| `cell_number`, `personal_email` | Contact info |
| `salutation` | Mr. / Ms. / Dr. etc. |
| `image` | Photo |
| `pan_number`, `aadhaar_number`, `passport_number`, `ssn` | Regional IDs |
| `bank_name`, `bank_ac_no`, `ifsc_code` | Bank details for payroll |
| `payroll_cost_center` | Cost center for salary GL posting |
| `holiday_list` | Link to Holiday List |

### Creating an employee

```python
emp = frappe.get_doc({
    "doctype": "Employee",
    "first_name": "Alice",
    "last_name": "Smith",
    "company": "Acme Corp",
    "date_of_joining": "2024-08-07",
    "department": "Engineering",
    "designation": "Senior Engineer",
    "employment_type": "Full-time",
    "reports_to": "EMP-0005",
    "user_id": "alice@acme.com",
    "cell_number": "+1-555-0100",
    "bank_name": "Chase",
    "bank_ac_no": "1234567890",
    "ifsc_code": "CHASUS33"
})
emp.insert()
```

### Employee → User link

When `user_id` is set:
- The linked User gets permissions from `Employee` role.
- The User can log in to Desk and see their own Employee record.
- Removing `user_id` severs the link.

### Programmatic queries

```python
# Get employee for current user
emp = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")

# Get all active employees in a department
employees = frappe.get_all("Employee",
    filters={"department": "Engineering", "status": "Active"},
    fields=["name", "employee_name", "designation"]
)

# Get manager chain
def get_managers(employee_name):
    chain = []
    current = employee_name
    while current:
        manager = frappe.db.get_value("Employee", current, "reports_to")
        if manager and manager not in chain:
            chain.append(manager)
            current = manager
        else:
            break
    return chain
```

## Attendance

`Attendance` records track daily presence.

### Fields

- `employee` — Link
- `attendance_date` — Date
- `status` — Present / Absent / Half Day / Work From Home
- `shift` — Link to Shift Type (optional)
- `leave_type` — Link (if absent due to leave)
- `leave_application` — Link to Leave Application (if applicable)
- `in_time`, `out_time` — Datetime (from biometric/punch system)
- `working_hours` — Float (computed from in/out times)
- `late_entry`, `early_exit` — Check
- `company` — Link

### Marking attendance

```python
# Manual
att = frappe.get_doc({
    "doctype": "Attendance",
    "employee": "EMP-0001",
    "attendance_date": "2024-08-07",
    "status": "Present"
})
att.insert()
att.submit()  # attendance is submittable

# Bulk via Employee Attendance Tool (Desk UI)
# Or programmatically
def mark_attendance_for_date(date, employees=None):
    if not employees:
        employees = frappe.get_all("Employee",
            filters={"status": "Active"},
            pluck="name"
        )

    for emp in employees:
        # Skip if already marked
        if frappe.db.exists("Attendance", {"employee": emp, "attendance_date": date}):
            continue

        att = frappe.get_doc({
            "doctype": "Attendance",
            "employee": emp,
            "attendance_date": date,
            "status": "Present"
        })
        att.insert()
        att.submit()
```

### Auto-attendance via Shift Type

Configure `Shift Type` to auto-mark attendance based on check-in/check-out logs:

```python
shift = frappe.get_doc({
    "doctype": "Shift Type",
    "shift_name": "Morning",
    "start_time": "09:00:00",
    "end_time": "17:00:00",
    "holiday_list": "Acme Holidays 2024",
    "allow_check_out_after_shift_end_time": 1,
    "working_hours_threshold_for_half_day": 4,
    "working_hours_threshold_for_absent": 2,
    "mark_auto_attendance_on_holidays": 0,
    "process_attendance_after": "2024-08-01",
    "last_sync_of_checkin": "2024-08-07 10:00:00"
})
shift.insert()
```

The scheduler then auto-creates Attendance records based on Employee Checkin entries.

### Employee Checkin

For biometric/punch-card integration:

```python
# From biometric API push
checkin = frappe.get_doc({
    "doctype": "Employee Checkin",
    "employee": "EMP-0001",
    "log_type": "IN",  # or "OUT"
    "time": "2024-08-07 09:05:00",
    "device_id": "DEVICE-001",
    "location": "Office Main Gate"
})
checkin.insert()
```

### Reports

- **Attendance Register** — monthly summary per employee
- **Monthly Attendance Sheet** — grid of dates × employees
- **Employee Absenteeism** — count of absences per month
- **Defaulters** — employees without attendance marked for a date

## Leave Management

Leave management involves several DocTypes working together:

### DocTypes

| DocType | Purpose |
|---|---|
| `Leave Type` | Master: Casual, Sick, Earned, etc. |
| `Leave Period` | Date range for leave accounting (e.g. Jan 1 - Dec 31) |
| `Leave Policy` | Template: how many days of each Leave Type per year |
| `Leave Policy Assignment` | Apply a Leave Policy to an Employee for a Leave Period |
| `Leave Allocation` | Specific allocation of N days of a Leave Type to an Employee |
| `Leave Application` | Employee requests leave (submittable) |
| `Leave Ledger Entry` | Audit trail of all leave transactions |
| `Holiday List` | List of holidays for a year |

### Leave Application workflow

```python
# Employee applies
leave = frappe.get_doc({
    "doctype": "Leave Application",
    "employee": "EMP-0001",
    "leave_type": "Casual Leave",
    "from_date": "2024-08-15",
    "to_date": "2024-08-17",
    "description": "Personal work",
    "half_day": 0,
    "half_day_date": None,
    "follow_via_email": 1,
    "status": "Open"
})
leave.insert()

# Approver approves
leave.status = "Approved"
leave.save()
leave.submit()
```

### Leave balance calculation

```python
from erpnext.hr.doctype.leave_application.leave_application import get_leave_balance_on

balance = get_leave_balance_on(
    employee="EMP-0001",
    leave_type="Casual Leave",
    date="2024-08-07",
    to_date="2024-12-31",
    consider_all_leaves_in_the_allocation_period=False,
    for_consumption=False
)
# balance is a dict: {"leave_allocation": 12.0, "leaves_taken": 3.0, "leave_balance": 9.0}
```

### Leave allocation

```python
# Allocate 12 days of Casual Leave to an employee
alloc = frappe.get_doc({
    "doctype": "Leave Allocation",
    "employee": "EMP-0001",
    "leave_type": "Casual Leave",
    "from_date": "2024-01-01",
    "to_date": "2024-12-31",
    "new_leaves_allocated": 12,
    "leave_period": "2024 Annual"
})
alloc.insert()
alloc.submit()
```

### Leave Policy

```python
policy = frappe.get_doc({
    "doctype": "Leave Policy",
    "policy_name": "Standard 2024",
    "leave_policy_details": [
        {"leave_type": "Casual Leave", "annual_allocation": 12},
        {"leave_type": "Sick Leave", "annual_allocation": 12},
        {"leave_type": "Earned Leave", "annual_allocation": 15}
    ]
})
policy.insert()

# Assign to all active employees
for emp in frappe.get_all("Employee", filters={"status": "Active"}, pluck="name"):
    assignment = frappe.get_doc({
        "doctype": "Leave Policy Assignment",
        "employee": emp,
        "leave_policy": "Standard 2024",
        "effective_from": "2024-01-01",
        "effective_to": "2024-12-31"
    })
    assignment.insert()
    assignment.submit()
```

## Payroll

Payroll generates Salary Slips from Salary Structures.

### Salary Structure

Defines earnings and deductions:

```python
structure = frappe.get_doc({
    "doctype": "Salary Structure",
    "name": "Engineer Standard",
    "company": "Acme Corp",
    "currency": "USD",
    "payroll_frequency": "Monthly",
    "is_active": "Yes",
    "mode_of_payment": "Bank",
    "earnings": [
        {
            "salary_component": "Basic",
            "abbr": "BASIC",
            "formula": "base * 0.5",  # 50% of CTC
            "amount_based_on_formula": 1
        },
        {
            "salary_component": "House Rent Allowance",
            "abbr": "HRA",
            "formula": "BASIC * 0.4",
            "amount_based_on_formula": 1
        },
        {
            "salary_component": "Special Allowance",
            "abbr": "SA",
            "formula": "base - BASIC - HRA",
            "amount_based_on_formula": 1
        }
    ],
    "deductions": [
        {
            "salary_component": "Provident Fund",
            "abbr": "PF",
            "formula": "BASIC * 0.12",
            "amount_based_on_formula": 1
        },
        {
            "salary_component": "Professional Tax",
            "abbr": "PT",
            "amount": 200,
            "amount_based_on_formula": 0
        }
    ]
})
structure.insert()

# Assign to employees
structure.assign_salary_structure(
    employees=["EMP-0001", "EMP-0002"],
    base=5000,
    variable=0,
    from_date="2024-08-01"
)
```

### Salary Component

Master for each earning/deduction. Has properties like:
- `type` — Earning / Deduction
- `is_tax_applicable` — counts toward taxable income
- `is_flexible_benefit` — non-taxable up to limit
- `depends_on_payment_days` — pro-rated if not full month worked
- `rounded_to` — round to nearest integer

### Salary Slip

Generated per employee per payroll period:

```python
# Generate one manually
slip = frappe.get_doc({
    "doctype": "Salary Slip",
    "employee": "EMP-0001",
    "start_date": "2024-08-01",
    "end_date": "2024-08-31",
    "salary_structure": "Engineer Standard",
    "company": "Acme Corp",
    "currency": "USD",
    "payroll_frequency": "Monthly"
})
slip.insert()
# Frappe auto-computes earnings, deductions, taxes, net_pay
slip.submit()
```

### Payroll Entry

Bulk-generate slips for all eligible employees:

```python
entry = frappe.get_doc({
    "doctype": "Payroll Entry",
    "company": "Acme Corp",
    "payroll_frequency": "Monthly",
    "start_date": "2024-08-01",
    "end_date": "2024-08-31",
    "payment_account": "Salaries Payable - AC",
    "cost_center": "Main - AC",
    "project": None,
    "branch": None,
    "department": "Engineering"  # filter to one department
})
entry.insert()

# Get employees
entry.fill_employee_details()

# Create salary slips
entry.create_salary_slips()
# Now status = "Submitted Salary Slips"

# Submit all slips
entry.submit_salary_slips()

# If accrual journal entry needed
entry.make_journal_entry(reference_date="2024-08-31", reference_number="JE-AUG-24")

# Submit
entry.submit()
```

### Payroll accounting

When `Payroll Entry` is submitted:
1. Creates a Journal Entry debiting salary expense per cost center.
2. Credits salary payable.
3. Per-employee Salary Slip records show breakdown.

For tax postings (TDS, PF, etc.), configure `Salary Component` → `Accounts` child table with debit/credit accounts per Company.

## Expense Claim

Employee expense reimbursement:

```python
claim = frappe.get_doc({
    "doctype": "Expense Claim",
    "employee": "EMP-0001",
    "expense_approver": "manager@acme.com",
    "posting_date": "2024-08-07",
    "company": "Acme Corp",
    "expenses": [
        {
            "expense_type": "Travel",
            "amount": 250.00,
            "sanctioned_amount": 250.00,
            "cost_center": "Engineering - AC",
            "description": "Flight to client site"
        },
        {
            "expense_type": "Food",
            "amount": 45.00,
            "sanctioned_amount": 40.00,  # approver reduced
            "cost_center": "Engineering - AC",
            "description": "Client lunch"
        }
    ],
    "total_sanctioned_amount": 290.00
})
claim.insert()

# Approver approves
claim.status = "Approved"
claim.save()
claim.submit()

# Pay out
# After submission, create Payment Entry to pay the employee
claim.make_payment_entry(payment_account="Cash - AC", mode_of_payment="Cash")
```

## Recruitment

### Job Opening

```python
opening = frappe.get_doc({
    "doctype": "Job Opening",
    "job_title": "Senior Backend Engineer",
    "designation": "Senior Engineer",
    "department": "Engineering",
    "company": "Acme Corp",
    "status": "Open",
    "employment_type": "Full-time",
    "description": "...",
    "publish_salary_range": 1,
    "lower_range": 80000,
    "upper_range": 120000,
    "currency": "USD",
    "job_application_route": "/jobs/senior-engineer"
})
opening.insert()
```

### Job Applicant

```python
applicant = frappe.get_doc({
    "doctype": "Job Applicant",
    "applicant_name": "Bob Johnson",
    "email_id": "bob@example.com",
    "phone_number": "+1-555-0123",
    "job_title": "Senior Backend Engineer",
    "status": "Open",
    "source": "Website"
})
applicant.insert()
```

### Job Offer

```python
offer = frappe.get_doc({
    "doctype": "Job Offer",
    "applicant": "JOB-APP-001",
    "job_offer_date": "2024-08-07",
    "status": "Awaiting Response",
    "designation": "Senior Engineer",
    "company": "Acme Corp",
    "offer_terms": [
        {"offer_term": "Base Salary", "value": "100,000 USD/year"},
        {"offer_term": "Joining Bonus", "value": "10,000 USD"},
        {"offer_term": "Start Date", "value": "2024-09-01"}
    ]
})
offer.insert()
```

When offer is accepted → create Employee record.

## Appraisal

Performance review cycle:

```python
appraisal = frappe.get_doc({
    "doctype": "Appraisal",
    "employee": "EMP-0001",
    "appraisal_cycle": "2024 Annual",
    "appraisal_template": "Engineering Template",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31",
    "appraisal_reviewer": "manager@acme.com",
    "kra_evaluation": [
        {"kra": "Code Quality", "per_weightage": 30, "goal_score": 4.5},
        {"kra": "Delivery", "per_weightage": 40, "goal_score": 4.0},
        {"kra": "Teamwork", "per_weightage": 30, "goal_score": 4.8}
    ],
    "total_score": 4.31  # auto-calculated
})
appraisal.insert()
appraisal.submit()
```

## Shift Management

### Shift Type

```python
shift = frappe.get_doc({
    "doctype": "Shift Type",
    "shift_name": "Morning",
    "start_time": "09:00:00",
    "end_time": "17:00:00",
    "holiday_list": "Acme 2024",
    "working_hours_threshold_for_half_day": 4,
    "working_hours_threshold_for_absent": 2,
    "process_attendance_after": "2024-08-01"
})
shift.insert()
```

### Shift Assignment

```python
assignment = frappe.get_doc({
    "doctype": "Shift Assignment",
    "employee": "EMP-0001",
    "shift_type": "Morning",
    "start_date": "2024-08-01",
    "end_date": "2024-12-31",
    "status": "Active"
})
assignment.insert()
assignment.submit()
```

### Shift Request

Employee-initiated shift change requests:

```python
request = frappe.get_doc({
    "doctype": "Shift Request",
    "employee": "EMP-0001",
    "shift_type": "Evening",
    "from_date": "2024-08-15",
    "to_date": "2024-08-31",
    "approver": "manager@acme.com",
    "status": "Draft"
})
request.insert()
```

## Employee Lifecycle

### Employee Onboarding

Template-based onboarding:

```python
template = frappe.get_doc({
    "doctype": "Employee Onboarding Template",
    "designation": "Senior Engineer",
    "department": "Engineering",
    "activities": [
        {"activity_name": "Create email account", "task_weight": 1},
        {"activity_name": "Issue laptop", "task_weight": 1},
        {"activity_name": "Setup payroll", "task_weight": 1},
        {"activity_name": "Orientation session", "task_weight": 1}
    ]
})
template.insert()

# Create actual onboarding
onboarding = frappe.get_doc({
    "doctype": "Employee Onboarding",
    "employee": "EMP-0001",
    "employee_onboarding_template": "Senior Engineer Template",
    "date_of_joining": "2024-08-15",
    "company": "Acme Corp",
    "status": "Pending"
})
onboarding.insert()
# This creates a Project + Tasks for each activity
```

### Employee Separation

```python
separation = frappe.get_doc({
    "doctype": "Employee Separation",
    "employee": "EMP-0001",
    "employee_separation_template": "Standard Exit",
    "relieving_date": "2024-12-31",
    "company": "Acme Corp",
    "status": "Pending"
})
separation.insert()
```

### Full & Final Settlement

When an employee leaves, the `Full and Final Settlement` DocType calculates outstanding:

```python
fnf = frappe.get_doc({
    "doctype": "Full and Final Settlement",
    "employee": "EMP-0001",
    "relieving_date": "2024-12-31",
    "company": "Acme Corp",
    "pay_salary_based_on_attendance_status": 1
})
fnf.insert()
# Frappe auto-populates:
# - Unpaid salary
# - Bonus / Incentives
# - Encashed leaves
# - Pending expense claims
# - Asset allocations to recover
# - Notice pay recovery (if applicable)
fnf.submit()
```

## Projects Module

ERPNext Projects cover project management, task tracking, and timesheets.

### Project DocType

```python
project = frappe.get_doc({
    "doctype": "Project",
    "project_name": "Customer Portal Redesign",
    "customer": "CUST-001",
    "project_template": "Standard Software Project",
    "status": "Open",
    "company": "Acme Corp",
    "expected_start_date": "2024-08-15",
    "expected_end_date": "2024-12-31",
    "project_type": "Internal",
    "priority": "High",
    "percent_complete_method": "Task Completion Ratio",
    "default_cost_center": "Engineering - AC",
    "users": [
        {"user": "alice@acme.com", "project_role": "Project Lead"},
        {"user": "bob@acme.com", "project_role": "Developer"}
    ]
})
project.insert()
project.submit()
```

### Task DocType

```python
task = frappe.get_doc({
    "doctype": "Task",
    "subject": "Design landing page",
    "project": "Customer Portal Redesign",
    "status": "Open",
    "priority": "High",
    "task_weight": 5,
    "exp_start_date": "2024-08-15",
    "exp_end_date": "2024-08-22",
    "expected_time": 16,  # hours
    "depends_on_tasks": [
        {"task": "TASK-0001"}  # this task depends on another
    ]
})
task.insert()

# Assign
task.assign_to = ["alice@acme.com"]
task.save()
```

### Task statuses

- Open
- Working
- Pending Review
- Completed
- Cancelled
- Template (if used as a template)

### Project Template

```python
template = frappe.get_doc({
    "doctype": "Project Template",
    "template_name": "Standard Software Project",
    "project_type": "Software",
    "tasks": [
        {"subject": "Requirements gathering", "task_weight": 5},
        {"subject": "Design", "task_weight": 10},
        {"subject": "Implementation", "task_weight": 20},
        {"subject": "Testing", "task_weight": 10},
        {"subject": "Deployment", "task_weight": 5}
    ]
})
template.insert()
```

When a Project is created with this template, all tasks are auto-created.

### Project analytics

```python
# Get project progress
project = frappe.get_doc("Project", "Customer Portal Redesign")
tasks = frappe.get_all("Task",
    filters={"project": project.name},
    fields=["name", "subject", "status", "task_weight", "expected_time", "actual_time"]
)

completed_weight = sum(t.task_weight for t in tasks if t.status == "Completed")
total_weight = sum(t.task_weight for t in tasks) or 1
project.percent_complete = (completed_weight / total_weight) * 100
project.save()
```

## Timesheets

Timesheets track time spent on Tasks / Projects / Activities.

```python
timesheet = frappe.get_doc({
    "doctype": "Timesheet",
    "employee": "EMP-0001",
    "company": "Acme Corp",
    "time_logs": [
        {
            "task": "TASK-0001",
            "project": "Customer Portal Redesign",
            "activity_type": "Development",
            "from_time": "2024-08-07 09:00:00",
            "to_time": "2024-08-07 12:00:00",
            "hours": 3.0,
            "description": "Implemented landing page layout"
        },
        {
            "task": "TASK-0001",
            "project": "Customer Portal Redesign",
            "activity_type": "Development",
            "from_time": "2024-08-07 13:00:00",
            "to_time": "2024-08-07 17:00:00",
            "hours": 4.0,
            "description": "Wrote tests for landing page"
        }
    ],
    "total_hours": 7.0
})
timesheet.insert()
timesheet.submit()

# Link to Sales Invoice for billing
timesheet.make_sales_invoice(customer="CUST-001", item_code="DEV-HOURLY")
```

## Issues

`Issue` DocType tracks customer-facing support tickets.

```python
issue = frappe.get_doc({
    "doctype": "Issue",
    "subject": "Cannot login",
    "customer": "CUST-001",
    "raised_by": "user@customer.com",
    "issue_type": "Functional",
    "priority": "High",
    "status": "Open",
    "description": "User reports 401 error on login"
})
issue.insert()

# Assign
issue.assign_to = "support@acme.com"
issue.save()

# Respond (creates Communication record)
issue.add_comment("Comment", "Looking into this...")

# Close
issue.status = "Closed"
issue.resolution_details = "User had wrong password. Reset via /forgot-password."
issue.resolved_by = "support@acme.com"
issue.resolution_date = frappe.utils.now()
issue.save()
```

### Issue workflow with SLA

Configure SLA per Issue Type:
- First Response Time: 2 hours
- Resolution Time: 24 hours

Frappe auto-tracks SLA compliance and escalates on breach.

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `Salary Slip not generated` | No active Salary Structure assigned | Run `Salary Structure Assignment` for the employee |
| `Leave balance insufficient` | Trying to apply leave without allocation | Create Leave Allocation first |
| `Employee not linked to User` | `user_id` field empty | Set Employee → User ID |
| `Attendance already exists` | Duplicate attendance for same date+employee | Check existing before inserting |
| `Payroll Entry failed` | Missing cost center or payment account | Configure `Payroll Settings` → default accounts |
| `Appraisal template missing` | No template assigned | Create `Appraisal Template` first |
| `Holiday List missing` | Employee or Shift Type has no holiday list | Create `Holiday List` and link |
| `Leave Application cannot be approved` | Approver not set or unauthorized | Set `leave_approver` field |
| `Timesheet cannot be submitted` | Project is closed or cancelled | Reopen Project or reassign Timesheet |
| `Expense Claim over budget` | Cost center budget exceeded | Increase budget or change cost center |

## Where to Learn More

- HR docs: https://docs.frappe.io/hr
- ERPNext HR: https://docs.frappe.io/erpnext/human-resources
- ERPNext Projects: https://docs.frappe.io/erpnext/projects
- Frappe HR GitHub: https://github.com/frappe/hrms
