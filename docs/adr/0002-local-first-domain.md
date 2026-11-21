# ADR 0002: Local-First Domain and Recurrence Modeling

## Status

Accepted

## Context

Routine occurrences must be available offline without duplicating recurring
task definitions for every day.

## Decision

Drift is the local source of truth. The domain calculates routine occurrences
from templates and stores only per-date state when an occurrence is changed.
Ad-hoc tasks remain independent dated records. Firestore is a synchronization
target, not a UI query source.

## Consequences

Agenda construction is deterministic and testable in pure Dart. Repository
implementations must persist local changes and their sync outbox entries
atomically.
