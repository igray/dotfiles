#!/usr/bin/env bash
# Toggle a hardware-encoded screen recording. Re-running while a recording is
# active stops it, so a single keybinding covers both start and stop.

set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/screenrecord.pid"
OUTPUT_DIR="$(xdg-user-dir VIDEOS 2>/dev/null || true)"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Videos}"

SELECT="region"
DESKTOP_AUDIO="false"
MICROPHONE_AUDIO="false"

usage() {
  cat <<'EOF'
Usage: screenrecord [--display] [--audio] [--mic] [--stop]

  --display  Select a whole display instead of dragging a region
  --audio    Record desktop output (default sink monitor)
  --mic      Record the microphone (default source); overrides --audio
  --stop     Stop an active recording and do nothing else

With no arguments, drag a region to start; run again to stop.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --display) SELECT="display" ;;
    --audio) DESKTOP_AUDIO="true" ;;
    --mic) MICROPHONE_AUDIO="true" ;;
    --stop) SELECT="stop" ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

recording_pid() {
  [[ -f $STATE_FILE ]] || return 1
  local pid
  pid="$(cat "$STATE_FILE")"
  [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null && echo "$pid"
}

stop_recording() {
  local pid=$1

  # wl-screenrec finalizes the container on SIGINT; SIGTERM truncates it.
  kill -SIGINT "$pid" 2>/dev/null || true

  local waited=0
  while kill -0 "$pid" 2>/dev/null && ((waited < 50)); do
    sleep 0.1
    waited=$((waited + 1))
  done

  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true
    notify-send -u critical -t 5000 "Screen recording" \
      "Recorder had to be force-killed; the video may be corrupt."
  else
    notify-send -t 3000 "Screen recording saved" "$OUTPUT_DIR"
  fi

  rm -f "$STATE_FILE"
}

start_recording() {
  mkdir -p "$OUTPUT_DIR"

  local geometry
  if [[ $SELECT == "display" ]]; then
    geometry="$(slurp -o -r -f '%x,%y %wx%h')" || exit 0
  else
    geometry="$(slurp -f '%x,%y %wx%h')" || exit 0
  fi
  [[ -n $geometry ]] || exit 0

  local audio_args=()
  if [[ $MICROPHONE_AUDIO == "true" ]]; then
    audio_args+=(--audio --audio-device "$(pactl get-default-source)")
  elif [[ $DESKTOP_AUDIO == "true" ]]; then
    audio_args+=(--audio --audio-device "$(pactl get-default-sink).monitor")
  fi

  local filename
  filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"

  # radeonsi exposes no low-power H264 entrypoint, so leaving this on auto costs
  # a failed encoder probe and a warning on every start.
  wl-screenrec --low-power=off --geometry "$geometry" \
    "${audio_args[@]}" --filename "$filename" &

  echo $! >"$STATE_FILE"
  notify-send -t 3000 "Screen recording started" "Run screenrecord again to stop."
}

if pid="$(recording_pid)"; then
  stop_recording "$pid"
elif [[ $SELECT == "stop" ]]; then
  rm -f "$STATE_FILE"
else
  start_recording
fi
