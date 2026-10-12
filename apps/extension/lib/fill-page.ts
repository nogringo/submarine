/**
 * Fills `username` and `password` into the sign-in form of the page, in fields a person sees, unless
 * the page left `origin` since its address was checked. Runs in the page: it refers to nothing
 * outside itself. Whether it filled a field.
 */
export function fillPage(
  origin: string,
  username: string | null,
  password: string | null,
): boolean {
  if (location.origin !== origin) return false;
  const fields = [...document.querySelectorAll("input")].filter((input) => {
    const box = input.getBoundingClientRect();
    return (
      !input.disabled &&
      !input.readOnly &&
      box.width > 0 &&
      box.height > 0 &&
      getComputedStyle(input).visibility !== "hidden"
    );
  });
  const textLike = (input: HTMLInputElement) => ["text", "email", "tel"].includes(input.type);
  const focused = fields.find((input) => input === document.activeElement);
  const passwords = fields.filter((input) => input.type === "password");
  const passwordField = focused?.type === "password" ? focused : passwords[0];
  const usernameField = passwordField
    ? // The closest before the password, in its form.
      fields
        .filter(
          (input) =>
            textLike(input) &&
            input.form === passwordField.form &&
            input.compareDocumentPosition(passwordField) & Node.DOCUMENT_POSITION_FOLLOWING,
        )
        .at(-1)
    : // A sign-in that asks for the username first, on a page of its own.
      ((focused && textLike(focused) ? focused : undefined) ??
      fields.find(
        (input) =>
          textLike(input) && /\b(username|email)\b/.test(input.getAttribute("autocomplete") ?? ""),
      ) ??
      fields.find((input) => input.type === "email"));
  const fill = (input: HTMLInputElement, value: string) => {
    input.focus();
    // Through the prototype: React keeps an input's value behind a setter of its own.
    Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value")?.set?.call(input, value);
    for (const type of ["input", "change"]) {
      input.dispatchEvent(new Event(type, { bubbles: true }));
    }
  };
  let filled = false;
  if (usernameField && username) {
    fill(usernameField, username);
    filled = true;
  }
  if (passwordField && password) {
    fill(passwordField, password);
    filled = true;
  }
  return filled;
}
