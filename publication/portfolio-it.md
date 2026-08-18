# Sahel Climate Actions
## Serious game multi-attore sulla Great Green Wall

**Ruolo:** Serious Game Designer & Developer  
**Piattaforma:** Tabletop Simulator  
**Stato:** Human Playtest Candidate  
**Release candidate:** v2.5 — agosto 2026

## La sfida di design

Come trasformare le dipendenze istituzionali legate a resilienza climatica e ripristino territoriale in decisioni realmente giocabili?

**Sahel Climate Actions** traduce il problema in una simulazione di quattro anni e ventiquattro stagioni bimestrali. Cinque attori asimmetrici operano sullo stesso sistema territoriale, combinando obiettivi condivisi, Projects, Interventions e Secret Missions private.

## Cinque attori asimmetrici

- **GOV:** autorizzazione, allocazione, delimitazione, deployment e sussidi;
- **FAO:** accompagnamento tecnico, mobilizzazione, distribuzione, preposizionamento e rafforzamento istituzionale;
- **GMV:** investimento territoriale, restauro, establishment, raccolta dell'acqua e manutenzione;
- **AGR:** semina, moltiplicazione, irrigazione, stoccaggio e adozione;
- **PAS:** mobilità delle mandrie, acqua, alimentazione, vaccinazione e mediazione.

Il sistema rende fisica la complementarità istituzionale: ciascun attore controlla soltanto una parte della catena causale.

## Sistema territoriale e risorse

La Common Board usa una matrice 3×3 organizzata per West/Central/East e North/Centre/South. Nove Territorial Cells sono collegate da quattordici connessioni permanenti. Sei Water Points alimentano un sistema di Common Water condiviso da attività agricole e pastorali.

Resources, Capacity, Presences, State Blocks, Herds, colture, Water Assets, Restoration sites e delimitazioni restano visibili sul tavolo e costituiscono evidenza persistente per Projects, Missions e debriefing.

## Architettura dell'informazione climatica

Ventiquattro Progress Cards definiscono la baseline stagionale. Sei mini-deck stagionali AGRHYMET/CILSS introducono sequenze Forecast/Outcome con intensità crescente:

- Year 1: ciclo stagionale ordinario, zero pair;
- Year 2: un pair per stagione;
- Year 3: due pair;
- Year 4: tre pair.

Ogni pair produce il ritmo:

**Forecast → intero ciclo di preparazione → Outcome.**

Le decisioni avvengono quindi prima di conoscere l'esito associato, mantenendo costi e vincoli ordinari.

## Carte e obiettivi

Il prototipo comprende **185 carte logiche / 370 facce**:

- 24 Progress;
- 36 pair AGRHYMET/CILSS;
- 75 Interventions;
- 25 Projects;
- 25 Secret Missions.

## Guided Turn Manager

È stato sviluppato direttamente in Tabletop Simulator un **Guided Turn Manager Lua** globale.

Il sistema guida setup delle carte, preparazione iniziale, Season Opening, avanzamento Progress, sequenza AGRHYMET/CILSS, actor cycles, cleanup e Final Resolution, lasciando ai giocatori la manipolazione fisica e la verifica della legalità.

L'interfaccia offre modalità FULL, COMPACT e HIDDEN, pulsante persistente SHOW GUIDE, posizionamento alto/basso, controllo opacità, tutorial text toggle, navigazione all'indietro e persistenza dello stato.

## Principio di design

Il prototipo privilegia **evidenza fisica visibile** rispetto alla ricostruzione narrativa a memoria. Carte, componenti, marker e stati della mappa mostrano ciò che gli attori hanno realmente abilitato, finanziato, mantenuto, prodotto o supportato.

## Stato corrente

Il tavolo TTS completo è assemblato: Common Board, cinque Actor Mats, famiglie di carte, riserve, Hidden Zones, State Blocks e Guided Turn Manager.

La release è classificata **Human Playtest Candidate**. Bilanciamento e validazione completa della sequenza tutorial restano oggetto del playtest empirico prima del freeze della versione v1.0 del tutorial.

## Nota sullo status pubblico

Il progetto è un prototipo sviluppato in modo indipendente. Nomi istituzionali e contesti di policy sono utilizzati come materia del serious game e come ruoli di gioco, senza implicare forme di endorsement o committenza istituzionale.
