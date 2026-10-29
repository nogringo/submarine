import { Composition, Still } from "remotion";
import { Thumbnail } from "./Thumbnail.tsx";
import { duration, fps } from "./timeline.ts";
import { Video } from "./Video.tsx";

export function Root() {
  return (
    <>
      <Composition
        id="Submarine"
        component={Video}
        durationInFrames={Math.round(duration * fps)}
        fps={fps}
        width={1920}
        height={1080}
      />
      <Still id="Thumbnail" component={Thumbnail} width={1280} height={720} />
    </>
  );
}
