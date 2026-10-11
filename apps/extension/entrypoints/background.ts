import { answerExtensionPages, loadCore } from "@/lib/core-host";

export default defineBackground(() => {
  answerExtensionPages(loadCore());
});
