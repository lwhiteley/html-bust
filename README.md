# html-bust

Cache-busts URLs in HTML files by appending a query string with a hash of the referenced resources. Similar to [grunt-cache-bust](http://www.npmjs.org/package/grunt-cache-bust), but runs on its own.

Because parsing and re-marshaling HTML documents is brittle, URLs are replaced through regular expressions. As a way to mitigate against unwanted substitutions, URLs that are to be busted can be marked with a special suffix.

## Usage

```
var bust = require('html-bust');
```

#### bust(inPath, outPath, [options], [done])

Rewrites the HTML file `inPath` to `outPath`, cache-busting URLs by appending a query string with a hash of the referenced resource. Relative URLs are resolved against the location of the HTML file; absolute URLs are ignored.

Available options:

* tagTypes (default: `[ 'img', 'script', 'link' ]`)

  An array of HTML tag types to cache-bust. Currently, `img`, `script` and `link` are supported. Tags of other types are ignored.

* urlHint (default: `'?bust'`)

  If set to a string, only URLs ending with that string are busted. The string is removed from the processed HTML file. If `null`, URLs are busted inconditionally.

* mode (default: `hash`)

  One of `hash` or `string` or `custom`. In `hash` mode, references are busted with a hash of the respective file contents, according to the `hashAlgorithm` and `hashString` options. In `string` mode, references are busted with the fixed string given by the `fixedString` option.

* hashAlgorithm (default: `'sha1'`)

  The hash algorithm to use in `hash` mode. Check the documentation for `crypto.createHash`.

* hashLength (default: `8`)

  The number of hash characters to use in `hash` mode as the cache-busting string.

* fixedString (default: `''`)

  The fixed string to use in `string` mode.

* customFunction (default: `() => ''`)

  The function to use in `custom` mode. Please ensure a string is returned by this function. If no string is returned then no replacements will be made.