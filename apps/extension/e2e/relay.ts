import { type Event, type Filter, matchFilter } from "nostr-tools";
import { type WebSocket, WebSocketServer } from "ws";

/** The relay the e2e build of the core uses for every vault: `TEST_RELAY` of `pnpm core:e2e`. */
export const relayUrl = "ws://127.0.0.1:4869";

/**
 * Starts a relay at `relayUrl` that keeps what it receives in memory, for the tests to reach no
 * relay of the network. Serves NIP-01 only, without authentication.
 */
export async function startRelay(): Promise<{ close(): Promise<void> }> {
  const events: Event[] = [];
  const subscriptions = new Map<WebSocket, Map<string, Filter[]>>();
  const server = new WebSocketServer({ host: "127.0.0.1", port: Number(new URL(relayUrl).port) });
  server.on("connection", (socket) => {
    const live = new Map<string, Filter[]>();
    subscriptions.set(socket, live);
    socket.on("close", () => subscriptions.delete(socket));
    const send = (message: unknown[]) => socket.send(JSON.stringify(message));
    socket.on("message", (data) => {
      const [type, ...rest] = JSON.parse(data.toString());
      if (type === "EVENT") {
        const event = rest[0] as Event;
        if (!events.some(({ id }) => id === event.id)) {
          events.push(event);
          for (const [other, otherLive] of subscriptions) {
            for (const [id, filters] of otherLive) {
              if (filters.some((filter) => matchFilter(filter, event))) {
                other.send(JSON.stringify(["EVENT", id, event]));
              }
            }
          }
        }
        send(["OK", event.id, true, ""]);
      } else if (type === "REQ") {
        const [id, ...filters] = rest as [string, ...Filter[]];
        live.set(id, filters);
        const matched = new Set<Event>();
        for (const filter of filters) {
          const newest = events
            .filter((event) => matchFilter(filter, event))
            .sort((a, b) => b.created_at - a.created_at)
            .slice(0, filter.limit ?? Number.POSITIVE_INFINITY);
          for (const event of newest) matched.add(event);
        }
        for (const event of matched) send(["EVENT", id, event]);
        send(["EOSE", id]);
      } else if (type === "CLOSE") {
        live.delete(rest[0]);
      } else {
        send(["NOTICE", `unsupported: ${type}`]);
      }
    });
  });
  await new Promise((listening) => server.once("listening", listening));
  return {
    close: () =>
      new Promise((closed) => {
        for (const socket of server.clients) socket.terminate();
        server.close(() => closed());
      }),
  };
}
