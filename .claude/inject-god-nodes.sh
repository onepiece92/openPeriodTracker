#!/usr/bin/env bash
# UserPromptSubmit hook: inject top god nodes (most-connected nodes by degree)
# from graphify-out/graph.json into the model's context.
set -e
GRAPH="/Users/aashishbijukchhe/Documents/anti/pTrack/graphify-out/graph.json"
[ -f "$GRAPH" ] || exit 0
command -v jq >/dev/null || exit 0

jq -n --rawfile g "$GRAPH" '
  ($g | fromjson) as $G
  | ($G.links | map(.source, .target) | group_by(.) | map({id: .[0], deg: length})) as $deg
  | ($G.nodes | map({(.id): .}) | add) as $byId
  | ($deg
      | sort_by(-.deg)
      | .[0:10]
      | map("- " + .id + " (deg " + (.deg | tostring) + ")" +
            (if $byId[.id] then " — " + ($byId[.id].label // "") +
              (if $byId[.id].source_file then " [" + $byId[.id].source_file + "]" else "" end)
             else "" end))
      | join("\n")) as $body
  | {hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: ("## Project god nodes (graphify, top 10 by degree)\n" + $body)
    }}
'
