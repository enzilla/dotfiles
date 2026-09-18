// ponytail: append a session list to the existing TUI sidebar.
import { For, createSignal } from "solid-js"

export default {
  id: "sessions-sidebar",
  tui: async (api) => {
    const [sessions, setSessions] = createSignal([])

    const refresh = async () => {
      try {
        const res = await api.client.session.list({
          directory: api.state.path.directory,
          roots: true,
          limit: 15,
        })
        const list = Array.isArray(res) ? res : res?.data ?? []
        setSessions(list.filter((s) => !s.parentID).slice(0, 12))
      } catch {
        // keep last list
      }
    }

    await refresh()
    api.event.on("session.created", refresh)
    api.event.on("session.updated", refresh)
    api.event.on("session.deleted", refresh)

    api.slots.register({
      slots: {
        sidebar_content: (_ctx, props) => (
          <box flexDirection="column" marginBottom={1}>
            <text fg={api.theme.current.textMuted}>sessions  ctrl+x l</text>
            <For each={sessions()} fallback={<text fg={api.theme.current.textMuted}>none</text>}>
              {(s) => (
                <text
                  fg={
                    s.id === props.session_id
                      ? api.theme.current.primary
                      : api.theme.current.text
                  }
                  onMouseDown={() => api.route.navigate("session", { sessionID: s.id })}
                >
                  {s.id === props.session_id ? "> " : "  "}
                  {(s.title || s.id).slice(0, 32)}
                </text>
              )}
            </For>
          </box>
        ),
      },
    })
  },
}
