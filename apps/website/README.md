# Submarine website

The site served at [submarine.li](https://submarine.li), built with [Astro](https://astro.build). It needs Node.js 24 and pnpm.

```sh
pnpm install
pnpm dev
```

## Languages

The site speaks the app's languages: English at `/`, the others under their code, such as `/fr` or `/pt-br`. Its strings are in [`l10n`](l10n): `website_en.arb` is the template, with a description of each string, and the other `website_<code>.arb` files its translations. Strings the app already has, such as its tagline and the names of the languages, come from the app's own ARB files. The privacy policy is the extension's [`PRIVACY.md`](../extension/PRIVACY.md), translated in [`src/privacy`](src/privacy): change the translations with it.

An English page offers a visitor whose browser prefers another language to read it in that language, until they pick one or close the offer.

## Checks

```sh
pnpm check       # Biome and astro check
pnpm test        # unit tests, every string and policy translated
pnpm a11y:browser
pnpm test:a11y   # axe on every page, light and dark, wide and at 320 pixels
```

The download page links the files of the latest GitHub release, read at build time. Without GitHub, its links lead to the release page.

## Deployment

[Firebase Hosting](https://firebase.google.com/docs/hosting) serves the site from the Firebase project `submarine-15385`, its Hosting site of the same name being the `website` target of the repository's [`firebase.json`](../../firebase.json) and [`.firebaserc`](../../.firebaserc). The domain `submarine.li` is connected to that site in the Firebase console, under Hosting.

The [website workflow](../../.github/workflows/website.yml) deploys it on each push to `main` that changes it, and after each release. It signs in with the repository secret `FIREBASE_SERVICE_ACCOUNT_SUBMARINE_15385`, the key of a service account that `firebase init hosting:github` created. To deploy by hand from the repository root, once the site is built:

```sh
firebase deploy --only hosting:website
```
