import { test, expect } from "bun:test";

const timeout = 10_000;
const interval = 100;

test(
  "caddy returns expected response",
  async () => {
    await Bun.sleep(interval); // wait for caddy to start
    const response = await fetch("http://test-app:8080");
    const body = await response.text();
    expect(body).toBe("Hello from test fixture!");
  },
  { retry: timeout / interval }
);
