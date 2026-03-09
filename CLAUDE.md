# Agent Script Authoring Guidelines

## Programmatic Style

Write agent reasoning in a programmatic, deterministic style using `instructions:->` procedures. Prefer explicit control flow over vague LLM instructions.

### Use `instructions:->` for conditional branching

```agentscript
reasoning:
    instructions: ->
        if not @variables.order_id:
            | Ask the customer for their order number.
        if @variables.order_id and not @variables.order_status:
            run @actions.get_order_status
                with order_id=@variables.order_id
                set @variables.order_status = @outputs.status
        if @variables.order_status == "delayed":
            | Apologize for the delay and explain the next steps.
        if @variables.order_status == "delivered":
            | Confirm delivery and ask if everything was satisfactory.
```

### Use `run @actions.X` for deterministic action execution

Use `run @actions.X` inside `instructions:->` when inputs are already stored in variables from a previous turn. All `with` bindings must use bound values — never `...`.

```agentscript
run @actions.get_flight_status
    with flight_number=@variables.flight_number
    set @variables.flight_status = @outputs.status
```

### Use `reasoning.actions` with `...` for same-turn user input collection

When you need to collect user input AND invoke an action in the same turn, put the action in `reasoning.actions` with slot-fill (`...`). Use `{!@actions.X}` in `|` instructions to tell the LLM when to invoke it.

```agentscript
reasoning:
    instructions: ->
        if @variables.auth_key == "":
            | Ask the customer for their email address.
            | When the customer provides their email, immediately invoke {!@actions.send_verification_code}.

    actions:
        send_verification_code: @actions.SendEmailVerificationCode
            available when @variables.auth_key == ""
            with customer_email = ...
            set @variables.auth_key = @outputs.auth_key
```

### Chain actions as post-action callbacks

After a `reasoning.actions` call, chain follow-up actions using `run`:

```agentscript
actions:
    make_payment: @actions.process_payment
        with amount=@variables.amount
        with method=@variables.method
        set @variables.transaction_id = @outputs.transaction_id
        run @actions.send_receipt
            with transaction_id=@variables.transaction_id
            set @variables.receipt_sent = @outputs.sent
```

## Block Ordering

Within every `topic` or `start_agent` block, always follow this order:

1. `description`
2. `system` (optional)
3. `actions` (topic-level action definitions with `target:`)
4. `reasoning` (contains `instructions` then `actions`)
5. `after_reasoning` (optional)

## Action Parameter Data Types for Special Field Types

Salesforce Date, DateTime, and other structured types cannot use plain `string` in action input/output definitions. Always use `object` with the appropriate `complex_data_type_name`.

| Field type | `complex_data_type_name`      |
|------------|-------------------------------|
| Date       | `lightning__dateType`         |
| DateTime   | `lightning__dateTimeStringType` |

Example:
```agentscript
inputs:
    expectedArrivalTime: object
        description: "New expected arrival time."
        label: "Expected Arrival Time"
        complex_data_type_name: "lightning__dateTimeStringType"
        is_required: False
        is_user_input: True

outputs:
    checkInDate: object
        description: "Scheduled check-in date."
        label: "Check In Date"
        complex_data_type_name: "lightning__dateType"
        filter_from_agent: False
```

## Key Rules

- `...` slot-fill is **only valid** in `reasoning.actions` bindings — never inside `run @actions.X`
- `run @actions.X` resolves against the topic-level `actions` block (those with `target:`), not `reasoning.actions` utilities
- `@utils.transition to` belongs in `reasoning.actions` only — use bare `transition to` in directive blocks (`after_reasoning`, post-action `if`)
- Boolean values must be capitalized: `True` / `False`
- Top-level block order: `config` → `variables` → `system` → `language` → `start_agent` → topics
