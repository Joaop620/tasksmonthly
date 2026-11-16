#!/usr/bin/env bash
# Cria milestones (semanas) e uma issue por dia a partir do PLANO.md. Requer `gh auth login`.
# Uso: ./scripts/criar-issues.sh [owner/repo]
set -euo pipefail
cd "$(dirname "$0")/.."
repo=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}

semanas=("Semana 1: API em Go" "Semana 2: CLI em Python" "Semana 3: Frontend Angular" "Semana 4: .NET, JS e entrega")
labels=("go" "python" "angular" "dotnet")
cores=("00ADD8" "3776AB" "DD0031" "512BD4")

for i in 0 1 2 3; do
  gh label create "${labels[$i]}" --color "${cores[$i]}" -R "$repo" --force >/dev/null
  gh api "repos/$repo/milestones" -f title="${semanas[$i]}" >/dev/null 2>&1 || true
done
gh label create "javascript" --color "F7DF1E" -R "$repo" --force >/dev/null
gh label create "infra" --color "6E7781" -R "$repo" --force >/dev/null

awk -F'|' '$2 ~ /^ *[0-9]+ *$/ {for(i=2;i<=4;i++){gsub(/^ +| +$/,"",$i)}; print $2 "\t" $3 "\t" $4}' PLANO.md |
while IFS=$'\t' read -r dia tarefa pronto; do
  s=$(( (dia - 1) / 7 )); (( s > 3 )) && s=3
  label=${labels[$s]}
  case $dia in 14|27|28|29|30) label=infra;; 25|26) label=javascript;; esac
  titulo=$(printf 'Dia %02d: %s' "$dia" "$(sed -E 's/\. .*//; s/`//g' <<<"$tarefa" | cut -c1-120 | sed -E "s/\.$//")")
  corpo=$(printf '## Tarefa\n%s\n\n## Pronto quando\n- [ ] %s\n\n_Tempo-alvo: 30 minutos. Feche com `closes #N` no commit._' "$tarefa" "$pronto")
  gh issue create -R "$repo" -t "$titulo" -b "$corpo" -l "$label" -m "${semanas[$s]}" >/dev/null
  echo "criada: $titulo"
done
