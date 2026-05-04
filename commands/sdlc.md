---
description: Run the full AI-powered SDLC pipeline against a feature description.
argument-hint: <feature description>
---

You are running the **sevaai-sdlc** pipeline.

The user wants to take the following feature through all seven SDLC stages end-to-end:

> $ARGUMENTS

Invoke the `sdlc-orchestrator` skill. It will create a dossier under `.sevaai-sdlc/{feature-slug}/` and walk through Requirements -> Design -> Development -> Testing -> Security -> Deployment -> Maintenance, writing one artifact per stage and an index file.

After all stages complete (or if security halts the pipeline), summarize:
- the feature slug and dossier path
- a one-line status per stage
- the top three risks identified across all stages
- the top three follow-ups the user should action this week
