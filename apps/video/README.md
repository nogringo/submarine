# Video

The presentation video of the [YouTube channel](https://www.youtube.com/@submarineli), made with [Remotion](https://www.remotion.dev): 83 seconds without a voice, its text taken from the site's and the app's catalogs, so its subtitles exist in every language they have.

## Making it

Each step writes into a folder git ignores. From this folder:

```sh
pnpm install
pnpm footage     # films the app, frame by frame, into public/footage/
pnpm soundtrack  # writes public/soundtrack.wav
pnpm render      # out/submarine.mp4 in 4K, and out/thumbnail.png
pnpm youtube     # out/youtube/: the title, description and subtitles of each language
```

`pnpm footage` runs [`tool/video_test.dart`](../app/tool/video_test.dart) in the app, a test that drives the real app over made-up vaults, as [`tool/screenshots_test.dart`](../app/tool/screenshots_test.dart) does, and keeps each frame, at four times the app's size for the 4K video. It takes four minutes or so, and 350 MB.

`pnpm studio` opens Remotion's editor, to watch the video as it is edited.

## Timeline

[`src/timeline.ts`](src/timeline.ts) gives the scenes, their length and the messages each shows, by their id in the catalogs. The video, the subtitles and the soundtrack's pings all follow it. The two takes of the app last as long as their scenes: a change to one goes with a change to the other.

## Uploading

On YouTube Studio, the video takes `out/thumbnail.png` as its thumbnail, and the title and description of `out/youtube/en.txt`. Under Languages, each other language gets its own title and description from `<language>.txt`, and its subtitles from `<language>.srt`.
