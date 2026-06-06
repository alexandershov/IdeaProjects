# Agentic Engineering

## What is it?
My walkthrough of:
* `[very good]` https://mitchellh.com/writing/my-ai-adoption-journey
* `[mostly fluff]` https://simonwillison.net/guides/agentic-engineering-patterns/
* `[fucking slop]` https://www.bassimeledath.com/blog/levels-of-agentic-engineering
* `[fucking slop]` https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents
Condensed to things that I found interesting/useful. Also contains my reflections on this.

## TLDR
* It may be worth it to err on a side it "yeah, let's build it" or "yeah, let's refactor it", if you think LLM can deal with it, and you won't need to spend much time on cleaning the slop.
* Use agents to do complicated git stuff (bisect, splitting commits, etc)
* Add knowledge to agents on how to do different things
* Use red/green TDD
* Ask agents to manually verify the code
* Ask agents to explain unfamiliar code for you
* Update AGENTS.md so the agent won't repeat its mistakes
* Review code with different model or at least from a clean session
* Launch agents in the last 30 minutes of the working day
* Outsource the slam dunks
* Give agents tools to verify their code
* "Is there is something agent can do right now and run in background?"

## LLMs
LLMs are stateless, so conversation "Hi", "yello", "How are you doing?", "fine" from the point of LLM is actually 2 requests 
that include all the previous conversation history:
1. request ["Hi"] -> response "yello"
2. request ["Hi", "yellow", "how are you doing?"] -> response "fine"

This means that every conversation with LLM has bunch of reduntant stuff (note that we passed "Hi" twice).
LLMs can cache repeated parts of conversation.

Harness is a terrible term (horse metaphors are not my shtick) for "prompts & tools that make LLM work as an agent".

Since tokens are expensive and (more importantly) LLM context is limited, a trick that is used by harnesses is
to create subagents with the clean context to do ... stuff, so the main agent don't have much context wasted.

## To build or not to build
Writing (garbage) code is cheap now. So it may be worth it to err on a side it "yeah, let's build it" or
"yeah, let's refactor it", if you think LLM can deal with it, and you won't need to spend much time on cleaning up the slop.

## Hoard things you know how to do
E.g. "i know how to start a service". Document it. Then LLM can use it. This stuff compounds and agents can be
useful.

## Testing
Add "use red/green TDD" to a prompt. This will force an agent to write tests to veryfy that code works.
Agents are good at automating boring stuff. 
Ask an agent to do manual testing of a feature: e.g. start a service locally, make requests to it.
Ask agent to create a proof-of-manual-testing document: commands it ran, results it got, etc.

## Agents and Git
Agents are good at git. Git is not super complicated, but annoying enough so we have tendencies to
take shortcuts (e.g. not splitting commits or not using bisect). With agents, you can just say:
* Extract changes in file X to a separate commit
* Split this change in 2 separate commits (first one is refactoring, second one is feature work)
* Find when bug was introduced with bisect
* Etc.

## Codebase Exploration
Ask agents to explain unfamiliar code for you, it will be sloppy, but may save you some time.

