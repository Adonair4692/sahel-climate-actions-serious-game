-- FAO / GREAT GREEN WALL / SAHEL
-- Guided Turn Manager v0.4 CARD TUTORIAL + VISIBILITY
-- Global Script for Tabletop Simulator
-- Guidance only: it does not move pieces or enforce legality.
--
-- Core timing:
--   Year 1 = 0 AGRHYMET/CILSS pairs per season + 1 ordinary GOV-to-PAS cycle
--   Year 2 = 1 pair per season
--   Year 3 = 2 pairs per season
--   Year 4 = 3 pairs per season
--
-- Visibility controls:
--   FULL / COMPACT / HIDDEN
--   TOP / BOTTOM
--   HIGH / DIM panel opacity
--   TUTORIAL ON / OFF
--   HIDDEN mode leaves a small SHOW GUIDE button
--   RESET GUIDE requires two clicks
--
-- State migration:
--   Saved state from older Guided Turn Manager versions is ignored once,
--   so this version starts clean at CARD SETUP.

local SCRIPT_VERSION = "0.4 CARD TUTORIAL"
local STATE_SCHEMA = 4

local function newState()
    return {
        schemaVersion = STATE_SCHEMA,
        mode = "setup",        -- setup | initial | season | final
        step = 1,
        season = 1,            -- 1..24
        tutorial = true,
        viewMode = "full",    -- full | compact | hidden
        position = "top",     -- top | bottom
        opacity = "high",     -- high | dim
        resetArmed = false
    }
end

local state = newState()

local periods = {
    "JANUARY-FEBRUARY",
    "MARCH-APRIL",
    "MAY-JUNE",
    "JULY-AUGUST",
    "SEPTEMBER-OCTOBER",
    "NOVEMBER-DECEMBER"
}

local actorColors = {
    GOV = "#800080",
    FAO = "#0072B2",
    GMV = "#008A68",
    AGR = "#B08B00",
    PAS = "#41F9ED"
}


local setupSteps = {
    {
        phase = "CARD SETUP",
        actor = "INTERVENTION DECK",
        hint = "Shuffle the 75-card Intervention deck. Leave VISIBLE DISCARD and COVERED DISCARD empty at setup."
    },
    {
        phase = "CARD SETUP",
        actor = "DEAL INTERVENTIONS",
        hint = "Each actor draws 4 Interventions privately, keeps 3 and returns exactly 1 face down. After all five returns, shuffle those returned cards back into the common deck."
    },
    {
        phase = "CARD SETUP",
        actor = "PROJECT CANDIDATES",
        hint = "Each actor shuffles its own 5 Projects, draws 3, keeps 2 privately and removes the third from play. The two candidates remain available through Year 1."
    },
    {
        phase = "CARD SETUP",
        actor = "SECRET MISSION",
        hint = "Each actor shuffles its own 5 Secret Missions, takes 1 random card face down into its TTS Hidden Zone and removes the other 4 from play. Keep the Mission hidden until Final Resolution."
    },
    {
        phase = "CARD SETUP",
        actor = "PROGRESS PREVIEW",
        hint = "Show Y1 JANUARY-FEBRUARY as the first Progress reference for Initial Preparation. Keep ACTIVE PROGRESS empty until that preparation cycle is complete."
    },
    {
        phase = "CARD SETUP",
        actor = "AGRHYMET MINI-DECKS",
        hint = "Prepare the six seasonal AGRHYMET/CILSS mini-decks JF, MA, MJ, JA, SO and ND. Keep them covered and ready. Year 1 draws zero AGRHYMET/CILSS pairs."
    }
}

local initialSteps = {
    {
        phase = "INITIAL PREPARATION",
        actor = "NEGOTIATION WINDOW",
        hint = "Open the pre-game Negotiation Window. Resolve legal transfers before GOV begins."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "GOV",
        hint = "GOV performs one legal normal action or passes. Use starting resources; this cycle grants no automatic recovery or replenishment."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "FAO",
        hint = "FAO performs one legal normal action or passes. Keep physical inputs and paid Capacity in their exact locations."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "GMV",
        hint = "GMV performs one legal normal action or passes. NEXT SEASON actions create their printed pending proof now."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "AGR",
        hint = "AGR performs one legal normal action or passes. Use the same physical Seed/Capacity required by the chosen action."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "PAS",
        hint = "PAS performs one legal normal action or passes. After this action the initial preparation cycle is complete."
    },
    {
        phase = "INITIAL PREPARATION",
        actor = "ACTIVATE FIRST PROGRESS",
        hint = "Move Y1 JANUARY-FEBRUARY into ACTIVE PROGRESS. Expose Y1 MARCH-APRIL at the top of the Progress Deck as the next visible seasonal baseline, then begin the first Season Opening."
    }
}

local openingSteps = {
    {
        phase = "SEASON OPENING",
        actor = "ACTIVATE PROGRESS",
        hint = "Advance the Progress system for the current season, then apply the printed opening text."
    },
    {
        phase = "SEASON OPENING",
        actor = "RECOVER CAPACITY",
        hint = "Recover ordinary paid Capacity. Preserve annual or effect-based commitments that explicitly remain committed."
    },
    {
        phase = "SEASON OPENING",
        actor = "ACTIVATE NEXT SEASON",
        hint = "Resolve eligible NEXT SEASON outputs and rotate eligible State Blocks before Water generation."
    },
    {
        phase = "SEASON OPENING",
        actor = "PAS STOCK TRANSFER",
        hint = "Move eligible PAS Feed/Veterinary from Protected to matching Deployable compartments, subject to printed capacity."
    },
    {
        phase = "SEASON OPENING",
        actor = "REPLENISH FUNDS",
        hint = "Add +1 Fund to GOV, +1 to FAO and +1 to GMV. AGR and PAS receive +0."
    },
    {
        phase = "SEASON OPENING",
        actor = "RESET SEASONAL BENEFITS",
        hint = "Reset eligible once-per-season READY/USED benefits for the new season before Water generation."
    },
    {
        phase = "SEASON OPENING",
        actor = "GENERATE WATER",
        hint = "Generate Water at each Water Point using the active Progress Card and Water Asset state: natural 1 / ACTIVE 2 = 2 / ACTIVE 3 = 3 / INACTIVE asset total 1, unless modified."
    }
}

local function addActorCycle(steps, phaseName, cycleHintPrefix)
    table.insert(steps, {
        phase = phaseName,
        actor = "NEGOTIATION WINDOW",
        hint = cycleHintPrefix .. " Open exactly one Negotiation Window before GOV. Resolve legal transfers now; after GOV begins, ownership transfer waits until the next window."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "INTERVENTION HAND MANAGEMENT",
        hint = "Before the acting actor's normal action, that actor may make at most one Intervention hand-management operation: BLIND REPLACEMENT, TAKE VISIBLE DISCARD, or NONE. Then the actor may declare an Intervention as allowed."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "INTERVENTION DRAW / DISCARD",
        hint = "BLIND REPLACEMENT: discard one hand card as the new face-up VISIBLE DISCARD, move the previous visible card face down to COVERED DISCARD, then draw 1 blind. TAKE VISIBLE: set the target aside, replace it with one hand card, then take the target. The original discarder cannot take its current visible card directly."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "INTERVENTION REPLACEMENT / RECYCLE",
        hint = "A DECLARED Intervention stays outside the hand. Draw 1 replacement immediately when it COMPLETES or FAILS. If the Intervention Deck becomes empty, reshuffle only eligible COVERED DISCARD cards; keep the current VISIBLE DISCARD and all declared, active, completed and failed cards out of the reshuffle."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "GOV",
        hint = cycleHintPrefix .. " GOV may manage/declare Interventions as allowed, then performs one legal normal action or passes."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "FAO",
        hint = cycleHintPrefix .. " FAO may manage/declare Interventions as allowed, then performs one legal normal action or passes."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "GMV",
        hint = cycleHintPrefix .. " GMV may manage/declare Interventions as allowed, then performs one legal normal action or passes."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "AGR",
        hint = cycleHintPrefix .. " AGR may manage/declare Interventions as allowed, then performs one legal normal action or passes."
    })
    table.insert(steps, {
        phase = phaseName,
        actor = "PAS",
        hint = cycleHintPrefix .. " PAS may manage/declare Interventions as allowed, then performs one legal normal action or passes."
    })
end

local function agrhymetPairsForSeason(seasonIndex)
    local year = math.floor((seasonIndex - 1) / 6) + 1
    if year == 1 then return 0 end
    if year == 2 then return 1 end
    if year == 3 then return 2 end
    return 3
end

local function progressOpeningHint(seasonIndex)
    if seasonIndex == 1 then
        return "Y1 JANUARY-FEBRUARY should already be in ACTIVE PROGRESS after Initial Preparation. Confirm it there, keep Y1 MARCH-APRIL visible at the top of the Progress Deck, and apply the printed opening text."
    end

    local function progressCardName(index)
        local year = math.floor((index - 1) / 6) + 1
        local period = periods[((index - 1) % 6) + 1]
        return "YEAR " .. year .. " — " .. period
    end

    local currentName = progressCardName(seasonIndex)
    if seasonIndex < 24 then
        local nextName = progressCardName(seasonIndex + 1)
        return "Move the previous Active Progress card to its resolved stack. Move " .. currentName .. " from the top of the Progress Deck into ACTIVE PROGRESS. Expose " .. nextName .. " at the top of the deck as the next visible seasonal baseline, then apply the current card's printed opening text."
    end

    return "Move the previous Active Progress card to its resolved stack. Move YEAR 4 — NOVEMBER-DECEMBER from the top of the Progress Deck into ACTIVE PROGRESS. The Progress Deck now has no next seasonal card to expose. Apply the printed opening text."
end

local function buildSeasonSteps(seasonIndex)
    local steps = {}

    for _, s in ipairs(openingSteps) do
        if s.actor == "ACTIVATE PROGRESS" then
            table.insert(steps, {
                phase = s.phase,
                actor = s.actor,
                hint = progressOpeningHint(seasonIndex)
            })
        else
            table.insert(steps, s)
        end
    end

    local pairCount = agrhymetPairsForSeason(seasonIndex)

    if pairCount == 0 then
        addActorCycle(
            steps,
            "ORDINARY ACTOR CYCLE",
            "YEAR 1: no AGRHYMET/CILSS card is used this season."
        )
    else
        for pairIndex = 1, pairCount do
            local pairPhase = "AGRHYMET / CILSS — PAIR " .. pairIndex .. " / " .. pairCount

            table.insert(steps, {
                phase = pairPhase,
                actor = "REVEAL FORECAST",
                hint = "Draw the next card from the AGRHYMET/CILSS mini-deck for the current season and place it Forecast-side up in FORECAST / ACTIVE. This is Forecast " .. pairIndex .. " of " .. pairCount .. ". Read the printed Forecast and Preparation Window exactly."
            })

            addActorCycle(
                steps,
                "PREPARATION ACTOR CYCLE — PAIR " .. pairIndex .. " / " .. pairCount,
                "This is the complete GOV-to-PAS preparation cycle for AGRHYMET/CILSS pair " .. pairIndex .. " of " .. pairCount .. "."
            )

            table.insert(steps, {
                phase = pairPhase,
                actor = "REVEAL OUTCOME",
                hint = "Reveal the paired Outcome immediately after this complete GOV-to-PAS cycle. Resolve it sequentially and preserve any required physical proof for carried effects."
            })
        end
    end

    table.insert(steps, {
        phase = "SEASON CLOSING",
        actor = "RESOLUTION / CLEANUP",
        hint = "Return Seasonal Support and unused Water as required; resolve the printed harvest/closing window; update only eligible territorial expiry; remove temporary markers at their exact timing."
    })

    return steps
end

local finalSteps = {
    {
        phase = "FINAL RESOLUTION",
        actor = "FREEZE EVIDENCE",
        hint = "Freeze the final map and all visible physical evidence before Secret Missions are revealed."
    },
    {
        phase = "FINAL RESOLUTION",
        actor = "FINAL PENDING OUTPUTS",
        hint = "Resolve only final pending outputs explicitly permitted at Final Resolution. Do not conduct a normal Season Opening."
    },
    {
        phase = "FINAL RESOLUTION",
        actor = "CLASSIFY PROJECTS",
        hint = "Classify each Project using its final visible evidence and permanent Y2/Y3/Y4 CHECK/X record."
    },
    {
        phase = "FINAL RESOLUTION",
        actor = "REVEAL SECRET MISSIONS",
        hint = "Reveal Secret Missions only now and verify them solely from the frozen visible evidence."
    },
    {
        phase = "FINAL RESOLUTION",
        actor = "SCORE / VICTORY",
        hint = "Calculate eligible Victory Paths and scores. Compare only eligible actors; equal highest eligible scores are Joint Winners."
    }
}

local UI_XML = [[
<Panel id="guidePanel"
       rectAlignment="UpperCenter"
       offsetXY="0 -24"
       width="900"
       height="372"
       color="#101820F2"
       outline="#D9D9D9"
       outlineSize="2 2">

    <Text id="gameTitleFull"
          rectAlignment="UpperCenter"
          offsetXY="0 -12"
          width="860"
          height="28"
          fontSize="20"
          fontStyle="Bold"
          color="#FFFFFF">FAO / GREAT GREEN WALL — GUIDED TURN MANAGER v0.4</Text>

    <Text id="seasonLabelFull"
          rectAlignment="UpperCenter"
          offsetXY="0 -48"
          width="860"
          height="28"
          fontSize="18"
          fontStyle="Bold"
          color="#E8E8E8">INITIAL PREPARATION</Text>

    <Text id="phaseLabelFull"
          rectAlignment="UpperCenter"
          offsetXY="0 -84"
          width="860"
          height="32"
          fontSize="24"
          fontStyle="Bold"
          color="#FFFFFF">INITIAL PREPARATION</Text>

    <Text id="actorLabelFull"
          rectAlignment="UpperCenter"
          offsetXY="0 -124"
          width="860"
          height="36"
          fontSize="27"
          fontStyle="Bold"
          color="#FFFFFF">NEGOTIATION WINDOW</Text>

    <Text id="hintLabelFull"
          rectAlignment="UpperCenter"
          offsetXY="0 -171"
          width="840"
          height="92"
          fontSize="17"
          color="#D7DEE7"
          alignment="UpperCenter"
          horizontalOverflow="Wrap"
          verticalOverflow="Truncate">Tutorial hint</Text>

    <Text id="progressLabelFull"
          rectAlignment="LowerCenter"
          offsetXY="0 112"
          width="500"
          height="22"
          fontSize="14"
          color="#AEB8C4">STEP</Text>

    <Button id="viewButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="-320 62"
            width="128"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="toggleViewMode">VIEW: FULL</Button>

    <Button id="tutorialButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="-184 62"
            width="136"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="toggleTutorial">TUTORIAL: ON</Button>

    <Button id="opacityButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="-42 62"
            width="136"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="toggleOpacity">PANEL: HIGH</Button>

    <Button id="positionButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="100 62"
            width="136"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="togglePosition">AT: TOP</Button>

    <Button id="hideButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="230 62"
            width="110"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="hideGuide">HIDE</Button>

    <Button id="resetButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="350 62"
            width="120"
            height="38"
            fontSize="13"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#7F1D1D|#991B1B|#450A0A|#555555"
            onClick="resetGuide">RESET GUIDE</Button>

    <Button id="backButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="-92 16"
            width="170"
            height="42"
            fontSize="17"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#4B5563|#6B7280|#374151|#555555"
            onClick="backStep">BACK</Button>

    <Button id="nextButtonFull"
            rectAlignment="LowerCenter"
            offsetXY="92 16"
            width="170"
            height="42"
            fontSize="17"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#166534|#15803D|#14532D|#555555"
            onClick="nextStep">NEXT STEP</Button>
</Panel>

<Panel id="compactPanel"
       rectAlignment="UpperCenter"
       offsetXY="0 -24"
       width="900"
       height="154"
       color="#101820F2"
       outline="#D9D9D9"
       outlineSize="2 2"
       active="false">

    <Text id="seasonLabelCompact"
          rectAlignment="UpperCenter"
          offsetXY="0 -10"
          width="860"
          height="24"
          fontSize="15"
          fontStyle="Bold"
          color="#E8E8E8">INITIAL PREPARATION</Text>

    <Text id="phaseLabelCompact"
          rectAlignment="UpperLeft"
          offsetXY="22 -40"
          width="410"
          height="30"
          fontSize="20"
          fontStyle="Bold"
          color="#FFFFFF">INITIAL PREPARATION</Text>

    <Text id="actorLabelCompact"
          rectAlignment="UpperRight"
          offsetXY="-22 -40"
          width="410"
          height="30"
          fontSize="21"
          fontStyle="Bold"
          alignment="UpperRight"
          color="#FFFFFF">NEGOTIATION WINDOW</Text>

    <Text id="progressLabelCompact"
          rectAlignment="LowerCenter"
          offsetXY="0 55"
          width="420"
          height="20"
          fontSize="13"
          color="#AEB8C4">STEP</Text>

    <Button id="viewButtonCompact"
            rectAlignment="LowerCenter"
            offsetXY="-330 10"
            width="120"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="toggleViewMode">VIEW: COMPACT</Button>

    <Button id="positionButtonCompact"
            rectAlignment="LowerCenter"
            offsetXY="-200 10"
            width="120"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="togglePosition">AT: TOP</Button>

    <Button id="hideButtonCompact"
            rectAlignment="LowerCenter"
            offsetXY="-80 10"
            width="100"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#334155|#475569|#1E293B|#555555"
            onClick="hideGuide">HIDE</Button>

    <Button id="backButtonCompact"
            rectAlignment="LowerCenter"
            offsetXY="75 10"
            width="150"
            height="38"
            fontSize="15"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#4B5563|#6B7280|#374151|#555555"
            onClick="backStep">BACK</Button>

    <Button id="nextButtonCompact"
            rectAlignment="LowerCenter"
            offsetXY="255 10"
            width="190"
            height="38"
            fontSize="15"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#166534|#15803D|#14532D|#555555"
            onClick="nextStep">NEXT STEP</Button>
</Panel>

<Panel id="launcherPanel"
       rectAlignment="UpperLeft"
       offsetXY="20 -20"
       width="176"
       height="48"
       color="#101820E8"
       outline="#D9D9D9"
       outlineSize="1 1"
       active="false">

    <Button id="showGuideButton"
            rectAlignment="MiddleCenter"
            width="164"
            height="38"
            fontSize="14"
            fontStyle="Bold"
            textColor="#FFFFFF"
            colors="#166534|#15803D|#14532D|#555555"
            onClick="showGuide">SHOW GUIDE</Button>
</Panel>
]]

local function seasonName(index)
    local year = math.floor((index - 1) / 6) + 1
    local period = periods[((index - 1) % 6) + 1]
    return "YEAR " .. year .. " — " .. period
end

local function currentSeasonSteps()
    return buildSeasonSteps(state.season)
end

local function clampState()
    if state.mode ~= "setup" and state.mode ~= "initial" and state.mode ~= "season" and state.mode ~= "final" then
        state.mode = "setup"
    end

    state.season = math.max(1, math.min(24, tonumber(state.season) or 1))
    state.step = tonumber(state.step) or 1

    if state.tutorial == nil then state.tutorial = true end
    if state.viewMode ~= "full" and state.viewMode ~= "compact" and state.viewMode ~= "hidden" then
        state.viewMode = "full"
    end
    if state.position ~= "top" and state.position ~= "bottom" then
        state.position = "top"
    end
    if state.opacity ~= "high" and state.opacity ~= "dim" then
        state.opacity = "high"
    end
    if state.resetArmed == nil then state.resetArmed = false end

    local maxStep = #setupSteps
    if state.mode == "initial" then maxStep = #initialSteps end
    if state.mode == "season" then maxStep = #currentSeasonSteps() end
    if state.mode == "final" then maxStep = #finalSteps end
    state.step = math.max(1, math.min(maxStep, state.step))
end

local function getCurrentStep()
    if state.mode == "setup" then
        return setupSteps[state.step]
    elseif state.mode == "initial" then
        return initialSteps[state.step]
    elseif state.mode == "season" then
        local steps = currentSeasonSteps()
        return steps[state.step]
    else
        return finalSteps[state.step]
    end
end

local function specialClosingHint(baseHint)
    if state.mode ~= "season" then
        return baseHint
    end

    local steps = currentSeasonSteps()
    if state.step ~= #steps then
        return baseHint
    end

    if state.season == 6 then
        return baseHint .. " YEAR 1 CLOSING: each actor must select one Project by this closing, even if it is not STARTED."
    elseif state.season == 12 then
        return baseHint .. " YEAR 2 CLOSING: place the permanent Y2 CHECK or X on each selected Project."
    elseif state.season == 18 then
        return baseHint .. " YEAR 3 CLOSING: place the permanent Y3 CHECK or X on each selected Project."
    elseif state.season == 24 then
        return baseHint .. " YEAR 4 CLOSING: place the permanent Y4 CHECK or X, then proceed to Final Resolution."
    end

    return baseHint
end

local function clearResetArm()
    state.resetArmed = false
end

local function atFinalEnd()
    return state.mode == "final" and state.step == #finalSteps
end

local function applyVisibility()
    UI.setAttribute("guidePanel", "active", state.viewMode == "full" and "true" or "false")
    UI.setAttribute("compactPanel", "active", state.viewMode == "compact" and "true" or "false")
    UI.setAttribute("launcherPanel", "active", state.viewMode == "hidden" and "true" or "false")
end

local function applyPosition()
    if state.position == "top" then
        UI.setAttribute("guidePanel", "rectAlignment", "UpperCenter")
        UI.setAttribute("guidePanel", "offsetXY", "0 -24")
        UI.setAttribute("compactPanel", "rectAlignment", "UpperCenter")
        UI.setAttribute("compactPanel", "offsetXY", "0 -24")
        UI.setAttribute("launcherPanel", "rectAlignment", "UpperLeft")
        UI.setAttribute("launcherPanel", "offsetXY", "20 -20")
    else
        UI.setAttribute("guidePanel", "rectAlignment", "LowerCenter")
        UI.setAttribute("guidePanel", "offsetXY", "0 24")
        UI.setAttribute("compactPanel", "rectAlignment", "LowerCenter")
        UI.setAttribute("compactPanel", "offsetXY", "0 24")
        UI.setAttribute("launcherPanel", "rectAlignment", "LowerLeft")
        UI.setAttribute("launcherPanel", "offsetXY", "20 20")
    end
end

local function applyOpacity()
    local fullColor = "#101820F2"
    local compactColor = "#101820F2"
    local launcherColor = "#101820E8"

    if state.opacity == "dim" then
        fullColor = "#101820B8"
        compactColor = "#101820B8"
        launcherColor = "#101820B8"
    end

    UI.setAttribute("guidePanel", "color", fullColor)
    UI.setAttribute("compactPanel", "color", compactColor)
    UI.setAttribute("launcherPanel", "color", launcherColor)
end

local function buildLabels()
    local seasonText = ""
    local progressText = ""

    if state.mode == "setup" then
        seasonText = "PRE-GAME — CARD SETUP"
        progressText = "CARD SETUP STEP " .. state.step .. " / " .. #setupSteps
    elseif state.mode == "initial" then
        seasonText = "PRE-GAME — INITIAL PREPARATION CYCLE"
        progressText = "INITIAL STEP " .. state.step .. " / " .. #initialSteps
    elseif state.mode == "season" then
        local steps = currentSeasonSteps()
        seasonText = seasonName(state.season) .. "   •   SEASON " .. state.season .. " / 24"
        progressText = "SEASON STEP " .. state.step .. " / " .. #steps
    else
        seasonText = "END OF YEAR 4 — FINAL RESOLUTION"
        progressText = "FINAL STEP " .. state.step .. " / " .. #finalSteps
    end

    return seasonText, progressText
end

function refreshUI()
    clampState()

    local s = getCurrentStep()
    local seasonText, progressText = buildLabels()
    local actorColor = actorColors[s.actor] or "#FFFFFF"

    UI.setValue("seasonLabelFull", seasonText)
    UI.setValue("phaseLabelFull", s.phase)
    UI.setValue("actorLabelFull", s.actor)
    UI.setValue("progressLabelFull", progressText)
    UI.setAttribute("actorLabelFull", "color", actorColor)

    UI.setValue("seasonLabelCompact", seasonText)
    UI.setValue("phaseLabelCompact", s.phase)
    UI.setValue("actorLabelCompact", s.actor)
    UI.setValue("progressLabelCompact", progressText)
    UI.setAttribute("actorLabelCompact", "color", actorColor)

    if state.tutorial then
        UI.setValue("hintLabelFull", specialClosingHint(s.hint))
        UI.setValue("tutorialButtonFull", "TUTORIAL: ON")
    else
        UI.setValue("hintLabelFull", "")
        UI.setValue("tutorialButtonFull", "TUTORIAL: OFF")
    end

    if state.opacity == "high" then
        UI.setValue("opacityButtonFull", "PANEL: HIGH")
    else
        UI.setValue("opacityButtonFull", "PANEL: DIM")
    end

    if state.position == "top" then
        UI.setValue("positionButtonFull", "AT: TOP")
        UI.setValue("positionButtonCompact", "AT: TOP")
    else
        UI.setValue("positionButtonFull", "AT: BOTTOM")
        UI.setValue("positionButtonCompact", "AT: BOTTOM")
    end

    UI.setValue("viewButtonFull", "VIEW: FULL")
    UI.setValue("viewButtonCompact", "VIEW: COMPACT")

    if state.resetArmed then
        UI.setValue("resetButtonFull", "CONFIRM RESET")
    else
        UI.setValue("resetButtonFull", "RESET GUIDE")
    end

    local nextText = "NEXT STEP"
    if atFinalEnd() then
        nextText = "FINISH / HIDE"
    end
    UI.setValue("nextButtonFull", nextText)
    UI.setValue("nextButtonCompact", nextText)

    applyVisibility()
    applyPosition()
    applyOpacity()
end

function nextStep(player, value, id)
    clearResetArm()

    if state.mode == "setup" then
        if state.step < #setupSteps then
            state.step = state.step + 1
        else
            state.mode = "initial"
            state.step = 1
        end

    elseif state.mode == "initial" then
        if state.step < #initialSteps then
            state.step = state.step + 1
        else
            state.mode = "season"
            state.season = 1
            state.step = 1
        end

    elseif state.mode == "season" then
        local steps = currentSeasonSteps()
        if state.step < #steps then
            state.step = state.step + 1
        else
            if state.season < 24 then
                state.season = state.season + 1
                state.step = 1
            else
                state.mode = "final"
                state.step = 1
            end
        end

    elseif state.mode == "final" then
        if state.step < #finalSteps then
            state.step = state.step + 1
        else
            state.viewMode = "hidden"
        end
    end

    refreshUI()
end

function backStep(player, value, id)
    clearResetArm()

    if state.mode == "setup" then
        if state.step > 1 then
            state.step = state.step - 1
        end

    elseif state.mode == "initial" then
        if state.step > 1 then
            state.step = state.step - 1
        else
            state.mode = "setup"
            state.step = #setupSteps
        end

    elseif state.mode == "season" then
        if state.step > 1 then
            state.step = state.step - 1
        elseif state.season > 1 then
            state.season = state.season - 1
            state.step = #buildSeasonSteps(state.season)
        else
            state.mode = "initial"
            state.step = #initialSteps
        end

    elseif state.mode == "final" then
        if state.step > 1 then
            state.step = state.step - 1
        else
            state.mode = "season"
            state.season = 24
            state.step = #buildSeasonSteps(state.season)
        end
    end

    refreshUI()
end

function toggleTutorial(player, value, id)
    clearResetArm()
    state.tutorial = not state.tutorial
    refreshUI()
end

function toggleViewMode(player, value, id)
    clearResetArm()
    if state.viewMode == "full" then
        state.viewMode = "compact"
    else
        state.viewMode = "full"
    end
    refreshUI()
end

function hideGuide(player, value, id)
    clearResetArm()
    state.viewMode = "hidden"
    refreshUI()
end

function showGuide(player, value, id)
    clearResetArm()
    state.viewMode = "full"
    refreshUI()
end

function togglePosition(player, value, id)
    clearResetArm()
    if state.position == "top" then
        state.position = "bottom"
    else
        state.position = "top"
    end
    refreshUI()
end

function toggleOpacity(player, value, id)
    clearResetArm()
    if state.opacity == "high" then
        state.opacity = "dim"
    else
        state.opacity = "high"
    end
    refreshUI()
end

function resetGuide(player, value, id)
    if state.resetArmed then
        state = newState()
    else
        state.resetArmed = true
    end
    refreshUI()
end

function onSave()
    return JSON.encode(state)
end

function onLoad(saved_data)
    local loadedState = nil

    if saved_data ~= nil and saved_data ~= "" then
        local ok, decoded = pcall(JSON.decode, saved_data)
        if ok and type(decoded) == "table" then
            loadedState = decoded
        end
    end

    -- Only restore state written by this schema.
    -- Older v0.1 / v0.2 / v0.3 saves start clean at CARD SETUP.
    if loadedState ~= nil and loadedState.schemaVersion == STATE_SCHEMA then
        state = loadedState
    else
        state = newState()
    end

    clampState()
    -- Reset confirmation must never remain armed across a save/load cycle.
    state.resetArmed = false
    UI.setXml(UI_XML)
    Wait.frames(refreshUI, 2)
end
