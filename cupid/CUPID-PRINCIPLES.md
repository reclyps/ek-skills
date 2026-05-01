# CUPID Principles Reference

Based on Dan North's "CUPID — for joyful coding" (2022). This is the evaluator's rubric.

---

## C — Composable: Plays Well With Others

**Core idea:** Code should be easy to use, discover, and integrate with other components without creating conflicts or unnecessary complexity.

**What to look for:**

- **Small surface area** — Narrow, opinionated APIs. Not so minimal that users must combine many together, not so expansive that they overwhelm. Each component/module exposes only what consumers need.
- **Intention-revealing** — Components are easy to find and assess. Clear naming, discoverable structure. A reader can understand what something does and whether it fits their need quickly.
- **Minimal dependencies** — Fewer external dependencies reduce version conflicts and maintenance burden. Even "innocuous" dependencies (logging, utility libraries) create transitive dependency management problems.
- **Composability by design** — Components can be combined, wrapped, extended, or replaced without modifying their internals. Slots, hooks, callbacks, and injection patterns over monolithic configurations.

**Anti-patterns:**
- God components that do everything and can't be used piecemeal
- Deep dependency trees that pull in the world
- APIs that require callers to understand internal implementation details
- Components that only work in one specific context or configuration

---

## U — Unix Philosophy: Does One Thing Well

**Core idea:** Each component should have a specific, focused purpose executed comprehensively. Small, focused units compose into powerful systems.

**What to look for:**

- **Single purpose** — Each module, hook, component, or function has one clear reason to exist. You can describe what it does in one sentence without using "and."
- **Simple, consistent model** — Inputs and outputs are predictable. The component transforms or presents data in one well-defined way.
- **Composable through pipelines** — Components chain together naturally. The output of one is a reasonable input to another. Data flows through clear paths.
- **Outside-in focus** — Purpose is defined by how users/consumers interact with it, not by internal code organization. This differs from Single Responsibility Principle (SRP), which is inside-out.

**Anti-patterns:**
- Components that handle both data fetching AND rendering AND state management AND error display
- Utility files that collect unrelated functions
- "Smart" components that know about multiple domain concerns
- Premature separation of things that change together (e.g., splitting UI and logic that always co-evolve into separate files for "separation of concerns")

---

## P — Predictable: Does What You Expect

**Core idea:** Code should behave consistently and reliably. Developers can confidently make changes without unpleasant surprises.

**What to look for:**

- **Behaves as expected** — Intended behavior is obvious from structure and naming. A reader can predict what the code does before reading the implementation. The code "passes all its tests" even without formal tests.
- **Deterministic** — Same inputs produce same outputs. Side effects are explicit and controlled. No hidden state mutations or surprising execution orders.
- **Robust** — Handles known situations completely. Clear about its limitations and edge cases. Validates at system boundaries.
- **Reliable** — Consistent results within its covered scenarios. Error states are handled explicitly, not silently swallowed.
- **Resilient** — Graceful handling of unexpected perturbations (network failures, missing data, race conditions). Degrades rather than crashes.
- **Observable** — Behavior can be inferred from outputs. Errors are surfaced with enough context to diagnose. Logging/telemetry where appropriate.
- **Tested** — Tests pin down expected behavior and document edge cases. Coverage is meaningful (behavioral, not just line-count).

**Anti-patterns:**
- Functions with surprising side effects not indicated by their name
- Silent error swallowing (empty catch blocks, fallback to defaults without logging)
- Non-deterministic behavior in supposedly pure functions
- Implicit dependencies on global state or execution order
- No tests for complex behavioral logic (hooks with fallback strategies, state machines, async flows)

---

## I — Idiomatic: Feels Natural

**Core idea:** Code should conform to established patterns and conventions of its language, ecosystem, and team. Idiomatic code reduces cognitive load and demonstrates empathy for future readers.

**What to look for:**

- **Language idioms** — Follows the community's established way of doing things. Uses language features as intended (e.g., TypeScript's type system, React's composition model, Go's error handling pattern).
- **Framework idioms** — Uses frameworks and libraries the way their authors intended. Follows recommended patterns from official documentation rather than fighting the framework.
- **Local idioms** — The team has established consistent patterns and follows them uniformly. When the language/framework doesn't prescribe one way, the team picks one and sticks with it. File structure, naming, component shape, error handling — all consistent.
- **Tooling alignment** — Linting, formatting, and type checking are configured and enforced. Code passes its own lint rules without suppressions scattered everywhere.
- **Empathy for readers** — Code is written for the next person to read it, not for the person writing it right now. Clever or unusual patterns are avoided unless they're the established team convention.

**Anti-patterns:**
- Mixing paradigms inconsistently (some files use classes, others functions, with no pattern to when)
- Fighting the framework (e.g., using refs to bypass React's data flow, manual DOM manipulation alongside a virtual DOM library)
- Inconsistent file naming, export styles, component shapes across the codebase
- Disabling linter rules frequently instead of conforming or reconfiguring
- "Clever" code that requires extra mental effort to parse

---

## D — Domain-Based: Solution Models the Problem Domain

**Core idea:** Code structure, naming, and organization should mirror the business domain's language and concepts. The cognitive distance between the problem and the solution should be minimal.

**What to look for:**

- **Domain language in code** — Types, variables, functions, and components use the language of the business domain, not generic technical terms. A domain expert reading the code can follow what it does. `Surname` instead of `string`, `Money(currency, amount)` instead of `float`.
- **Domain-based structure** — Directory layout reflects business domains, not technical layers. Code for a feature/domain concept lives together rather than being scattered across `models/`, `views/`, `controllers/`, `types/`, `utils/` directories.
- **Domain-based boundaries** — Module boundaries align with domain boundaries. Related code deploys together. Changes to one domain concept don't scatter across unrelated modules.
- **Types encode domain constraints** — The type system captures business rules (union types for valid states, branded types for domain identifiers, enums for fixed domain vocabularies) rather than using primitives everywhere.
- **Ubiquitous language** — The same terms are used consistently in code, documentation, and conversation. No translation layer between what the team calls something and what the code calls it.

**Anti-patterns:**
- Generic names everywhere (`data`, `item`, `value`, `result`, `handler`, `manager`, `service`)
- Framework-driven directory structure that scatters domain concepts (Rails-style `models/`, `views/`, `controllers/`)
- Primitive obsession — using `string`, `number`, `boolean` where domain types would add clarity and safety
- Code organization that requires touching 5+ files across different directories to change one domain concept
- Translation gaps between what stakeholders call something and what the code calls it

---

## Interconnection

The five properties are mutually reinforcing:
- **Composable** components that **do one thing** are naturally **predictable**
- **Domain-based** code written **idiomatically** feels natural and **composes** well
- **Predictable** code frees mental cycles for **domain** reasoning
- **Idiomatic** code is easier to assess for **composability** and **predictability**

When evaluating, note where principles reinforce or conflict with each other in the target code.
