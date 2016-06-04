# History

## v2.5.0 2016 June 4
- Updated dependencies
- Converted from CoffeeScript to ESNext
- Removed `attach` and `inheritInto`, they were not used by anybody
- Export EventEmitterGrouped directly, alias as static property for backwards compatibility

## v2.4.3 2014 June 24
- Fixed publish

## v2.4.2 2014 June 24
- Fixed publish

## v2.4.1 2014 June 16
- Removed `events-browser` implied dependency, as browserify shim now works

## v2.4.0 2014 June 16
- Updated dependencies

## v2.3.3 2014 January 30
- Possible fix for priorities on events bound by once
- TaskGroup and Tasks are now named by default

## v2.3.2 2013 November 6
- Dropped component.io and bower support, just use ender or browserify
- Updated dependencies

## v2.3.1 2013 October 27
- Re-packaged

## v2.3.0 2013 July 12
- Split out from [bal-util](https://github.com/balupton/bal-util)
- Added support for splat arguments
