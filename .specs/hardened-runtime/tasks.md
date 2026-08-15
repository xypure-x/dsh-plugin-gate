# Tasks: Hardened Runtime

Strategy: Risk-first, then Linux baseline and verification.

## Phase 1: Specification

- [x] 1.1 Define Linux-first security requirements and trust boundaries.
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.4_

## Phase 2: Implementation

- [x] 2.1 Create Linux-first project baseline.
  - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - Depends on: 1.1
- [x] 2.2 Remove unrestricted executable staging and restrict persistence.
  - _Requirements: 2.1, 2.2, 2.4, 5.2_
  - Depends on: 2.1
- [x] 2.3 Add trusted-path, package, command, and recovery guards.
  - _Requirements: 2.3, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 5.1, 5.3
  - Depends on: 2.1

## Phase 3: Verification gate

- [x] 2.4 Run typecheck and static security gate.
  - _Requirements: 1.4, 2.1, 2.3, 3.2, 5.4
  - Depends on: 2.2, 2.3

## Task Dependency Graph

```text
1.1
 |
2.1
 |-- 2.2 --\
 |          2.4
 `-- 2.3 --/
```

## Status Block

- Progress: 4/4 implementation tasks complete (100%)
- Current task: completed
- Gate chain: 2.4 passed
