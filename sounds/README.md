#### What happened here:

1. Go to Parse to `Sounds` collection
1. Export it to `Sounds.json`
1. save it to `sounds/` directory
1. `cd sounds/`
1. Run `coffee changeSoundsFormat.coffee`
1. It changes collection structure and saves it to `Sounds2.json`
1. Import `Sounds2.json` to Parse
1. Run `coffee retrieveFromParse.coffee`
1. `TODO:` Write script that syncs files between (Parse <-> File System)
