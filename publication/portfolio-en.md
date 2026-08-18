# Sahel Climate Actions
## A Great Green Wall Multi-Actor Serious Game Prototype

**Role:** Serious Game Designer & Developer  
**Platform:** Tabletop Simulator  
**Status:** Human Playtest Candidate  
**Release candidate:** v2.5 — August 2026

## The design challenge

How can a serious game make the institutional dependencies behind climate resilience and land restoration visible as playable decisions rather than as abstract policy descriptions?

**Sahel Climate Actions** turns the problem into a four-year, twenty-four-season multi-actor simulation. Five asymmetric roles must operate on the same territorial system while pursuing shared outcomes, Projects, Interventions and private Secret Missions.

## Five asymmetric actors

- **GOV:** authorization, allocation, delimitation, deployment and subsidy;
- **FAO:** accompaniment, mobilization, distribution, prepositioning and institutional strengthening;
- **GMV:** territorial investment, restoration, establishment, water harvesting and maintenance;
- **AGR:** sowing, multiplication, irrigation, storage and adoption;
- **PAS:** herd movement, watering, feeding, vaccination and mediation.

The design makes institutional complementarity physical: no actor controls the entire causal chain.

## Territorial and resource system

The Common Board uses a 3×3 territorial matrix across West, Central and East and North, Centre and South. Nine territorial cells are linked by fourteen permanent connections. Six Water Points create a shared Common Water system supporting pastoral and agricultural activity.

Resources, Capacity, Presences, State Blocks, Herds, crops, Water Assets, Restoration sites and territorial delimitations remain visible on the table, creating a persistent evidence state for later Projects, Missions and debriefing.

## Climate-information architecture

Twenty-four Progress cards establish the seasonal baseline. Six AGRHYMET/CILSS seasonal mini-decks introduce escalating Forecast/Outcome sequences:

- Year 1: ordinary seasonal cycle, zero pairs;
- Year 2: one pair per season;
- Year 3: two pairs;
- Year 4: three pairs.

Every pair creates an anticipatory-action rhythm:

**Forecast → complete preparation actor cycle → Outcome.**

Players therefore act before knowing the paired result while remaining subject to ordinary action costs and territorial constraints.

## Card and objective systems

The prototype contains **185 logical cards / 370 faces**:

- 24 Progress cards;
- 36 AGRHYMET/CILSS Forecast/Outcome pairs;
- 75 Interventions;
- 25 Projects;
- 25 Secret Missions.

Interventions provide medium-term operational objectives, Projects create actor-specific annual evidence pathways, and Secret Missions preserve private incentives until Final Resolution.

## Guided Turn Manager

A custom Global Lua **Guided Turn Manager** was developed directly in Tabletop Simulator.

It guides card setup, the initial preparation cycle, Season Opening, Progress advancement, AGRHYMET/CILSS timing, actor cycles, cleanup and Final Resolution while deliberately leaving physical manipulation and legality assessment to the players.

The interface supports FULL, COMPACT and HIDDEN visibility, a small persistent SHOW GUIDE control, top/bottom positioning, opacity control, tutorial text toggle, backward navigation and save-state persistence.

## Design principle

The prototype prioritizes **visible physical evidence** over remembered narrative. Components, cards, markers and board states show what institutions have actually enabled, invested, maintained, produced or supported.

That makes the game usable not only as an educational activity, but also as a structured basis for observing coordination, bottlenecks, anticipatory choices and competing institutional incentives during playtests.

## Current state

The complete TTS table is assembled with Common Board, five Actor Mats, all card families, common and actor reserves, Hidden Zones, State Blocks and Guided Turn Manager.

The current release is deliberately labelled **Human Playtest Candidate**. Balance and the complete Guided Turn Manager sequence remain subject to empirical playtesting before a final v1.0 tutorial freeze.

## Public-status note

This is an independently developed prototype. Institutional names and policy contexts are used as subject matter and gameplay roles; no official commission or endorsement is implied.
