declare module "*.arb" {
  const messages: Record<string, string>;
  export default messages;
}

declare module "*.woff2" {
  const url: string;
  export default url;
}

declare module "*.svg" {
  const url: string;
  export default url;
}

declare module "*.dart" {
  const source: string;
  export default source;
}
