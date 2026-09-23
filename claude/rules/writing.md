# Writing Rules

Applies to all prose you write: chat responses, commit messages, PR descriptions,
code comments, documentation, and any other generated text.

## Punctuation

- Never use en dashes (–) or em dashes (—) as sentence punctuation.
- Use a comma, colon, parentheses, or a separate sentence instead.
- Numeric ranges are the exception: a hyphen or an en dash is fine
  (e.g. "5-10" or "5–10").
- A regular hyphen (-) is fine in hyphenated words and flags.

## Spelling

- Use US English spelling, not British English.
- color not colour, behavior not behaviour, license not licence
- organize not organise, analyze not analyse, canceled not cancelled
- center not centre, catalog not catalogue, defense not defence
- Keep the original spelling when quoting existing code, identifiers, APIs, or
  third party text verbatim.

## Conciseness

- Lead with the answer or the result, then add context only if it is needed.
- Cut preamble ("Great question", "Let me explain", "I'll now...") and cut
  closing summaries that repeat what was just said.
- Do not restate the question back to me before answering it.
- Prefer the shortest form that stays accurate. If a sentence can lose words
  without losing meaning, lose them.
- One idea per sentence. Split long sentences instead of joining them with
  semicolons or subordinate clauses.
- Do not pad with hedges ("it seems", "arguably", "in general") unless the
  uncertainty is real and worth flagging.
- Use bullets for lists of things, prose for reasoning. Do not turn a two item
  list into a table.
- No filler adjectives ("comprehensive", "robust", "powerful", "seamless") and
  no marketing tone.
- Never claim work is done, tested, or verified unless it actually is.

## Plain English

- Invoke the `simple-english` skill before writing or rewriting these:
  documentation, READMEs, runbooks, PR descriptions, commit messages, release
  notes, incident reports, and user facing error messages.
- Chat replies do not need the skill, but they still follow the conciseness
  rules above.
- Use it on request whenever I say "plain English", "simple English", "STE",
  or "no jargon".
- Explain a technical term the first time it appears, or replace it with a
  common word.
