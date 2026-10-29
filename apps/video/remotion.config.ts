import { Config } from "@remotion/cli/config";

Config.setEntryPoint("src/index.ts");
// 3840 by 2160, from compositions laid out in 1920 by 1080.
Config.setScale(2);
Config.setVideoImageFormat("png");
Config.setCodec("h264");
Config.setCrf(14);
Config.overrideWebpackConfig((config) => {
  config.module ??= {};
  config.module.rules ??= [];
  // The catalogs of the app and the site.
  config.module.rules.push({ test: /\.arb$/, type: "json" });
  // The code the open source scene shows.
  config.module.rules.push({ test: /\.dart$/, type: "asset/source" });
  return config;
});
