#!/usr/bin/env python3
"""Quem usa um símbolo compartilhado, agrupado por repositório.

O `graphify explain` mostra as conexões de um nó, mas no grafo global ele não
diz de qual repositório vem cada uma. Este script resolve isso.

    ~/.graphify/quem-usa.py BaseService
    ~/.graphify/quem-usa.py crud.Coded --detalhe
    ~/.graphify/quem-usa.py dp-bk-messaging          # lista o que casar

Sem argumento, lista os símbolos compartilhados por mais repositórios.
"""
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

BASE = Path.home() / ".graphify"
GRAFO = BASE / "global-graph.json"
MANIFESTO = BASE / "global-manifest.json"


def carregar():
    if not GRAFO.exists():
        sys.exit(f"grafo global não encontrado em {GRAFO} — rode a varredura primeiro")
    g = json.loads(GRAFO.read_text(encoding="utf-8"))
    tags = set(json.loads(MANIFESTO.read_text(encoding="utf-8"))["repos"])
    return g["nodes"], (g.get("links") or g["edges"]), tags


def repo_de(nid, tags):
    p = str(nid).split("::", 1)[0]
    return p if p in tags else None


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    detalhe = "--detalhe" in sys.argv
    nodes, links, tags = carregar()
    por_id = {n["id"]: n for n in nodes}

    # símbolos compartilhados = nós sem source_file (dependências externas)
    externos = {n["id"]: (n.get("label") or n["id"]) for n in nodes if not n.get("source_file")}

    if not args:
        alcance = defaultdict(set)
        for l in links:
            for a, b in ((l["source"], l["target"]), (l["target"], l["source"])):
                if a in externos and (r := repo_de(b, tags)):
                    alcance[a].add(r)
        print("símbolos compartilhados por mais repositórios:\n")
        for nid, repos in sorted(alcance.items(), key=lambda x: -len(x[1]))[:30]:
            print(f"  {len(repos):3} repos  {externos[nid]}")
        print("\nuse: quem-usa.py <trecho-do-símbolo>")
        return

    termo = args[0].lower()
    achados = [nid for nid, lab in externos.items() if termo in lab.lower()]
    if not achados:
        sys.exit(f"nenhum símbolo compartilhado casa com {args[0]!r}")
    if len(achados) > 1 and not any(externos[n].lower().endswith(termo) for n in achados):
        print(f"{len(achados)} símbolos casam com {args[0]!r}:\n")
        for nid in sorted(achados, key=lambda n: externos[n])[:40]:
            print(f"  {externos[nid]}")
        return

    for nid in achados:
        usos = Counter()
        locais = defaultdict(list)
        for l in links:
            for a, b in ((l["source"], l["target"]), (l["target"], l["source"])):
                if a == nid and (r := repo_de(b, tags)):
                    usos[r] += 1
                    n = por_id.get(b, {})
                    locais[r].append(f"{n.get('label', b)} — {n.get('source_file', '?')}")
        if not usos:
            continue
        print(f"\n{externos[nid]}")
        print(f"  {sum(usos.values())} usos em {len(usos)} repositórios\n")
        for r, q in usos.most_common():
            print(f"  {r:18} {q}")
            if detalhe:
                for loc in sorted(set(locais[r]))[:12]:
                    print(f"      {loc}")


if __name__ == "__main__":
    main()
