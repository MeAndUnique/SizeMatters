# Size Matters
Adds support for effects that change creature size, space, and reach.

Size Matters is intended to work with any ruleset based on CoreRPG. The SPACE and REACH based effects below are system agnostic, applying specifically to the token. The SIZE effects below make certain assumptions about how the ruleset handles size categories. Support is verified for D&D 5E to account for SIZE changes with encumbrance and IF: SIZE() conditional effects. Mileage for other rulesets may vary.

The following effects have been added:
* **SIZE: n** - Adjusts the bearer n number of size increments. E.g. "SIZE: 2" will turn a small creature into a large creature.
* **SIZE: size** - Makes the bearer the given size. The allowed values for size are determined by the ruleset (for any ruleset that uses "DataCommon.creaturesize").
* **SPACE: n** - Sets the bearer's space to n, using the ruleset's unit of distance.
* **ADDSPACE: n** - Adds n to the bearer's reach, using the ruleset's unit of distance.
* **REACH: n** - Sets the bearer's reach to n, using the ruleset's unit of distance.
* **ADDREACH: n** - Adds n to the bearer's reach, using the ruleset's unit of distance.

## Installation
Download [SizeMatters.ext](https://github.com/MeAndUnique/SizeMatters/releases) and place in the extensions subfolder of the Fantasy Grounds data folder.

## Attribution
SmiteWorks owns rights to code sections copied from their rulesets by permission for Fantasy Grounds community development.
'Fantasy Grounds' is a trademark of SmiteWorks USA, LLC.
'Fantasy Grounds' is Copyright 2004-2021 SmiteWorks USA LLC.

<a href="https://www.vecteezy.com/">Vectors by Vecteezy</a>