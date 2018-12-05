# History

## v2.7.1 2018 September 3
- Updated base files and [editions](https://github.com/bevry/editions) using [boundation](https://github.com/bevry/boundation)

## v2.7.0 2018 August 19
- Updated base files and [editions](https://github.com/bevry/editions) using [boundation](https://github.com/bevry/boundation)

## v2.6.1 2018 July 13
- Delegated ambi invocation to taskgroup, where it rightfully belongs
- Updated dependencies

## v2.6.0 2018 July 13
- More detailed and accurate task names for listeners
- Better listener argument length detection thanks to [unbounded](https://github.com/bevry/unbounded)
- Better listener argument length detection on `once` events on Node v10 and Node v8
- Updated base files using [boundation](https://github.com/bevry/boundation)
- Updated dependencies

## v2.5.0 2016 June 4
- Converted from CoffeeScript to ESNext
- Removed `attach` and `inheritInto`, they were not used by anybody
- Export EventEmitterGrouped directly, alias as static property for backwards compatibility
- Updated dependencies

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
