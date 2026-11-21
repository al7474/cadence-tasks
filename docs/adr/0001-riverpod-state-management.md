# ADR 0001: Riverpod for State Management and Dependency Injection

## Status

Accepted

## Context

The app needs testable dependency injection and explicit asynchronous UI states
across Android and Web without coupling feature domains to Flutter.

## Decision

Use Riverpod with code generation for presentation state and dependency wiring.
Keep repositories and use cases behind typed providers; override providers in
tests instead of introducing a separate service locator.

## Consequences

Providers remain in the presentation/composition layers. Domain entities and
use cases stay independent of Riverpod and Flutter.
