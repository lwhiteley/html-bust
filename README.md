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

* hashAlgorithm (default: `'sha1'`)

  The hash algorithm to use. Check the documentation for `crypto.createHash`.

* hashLength (default: `8`)

  The number of characters to use as the cache-busting string.
