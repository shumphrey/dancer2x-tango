Dancer2x::Tango
===============

This is an experimental prototype layout for a Dancer2 application.

It tries to solve the following problems:

- Modules with long complex callback style subroutines *can* make for spaghetti code (highly subjective).
- Dancer2 exports a *lot* of DSL which can conflict with other imports.

Complexity
----------

MVC is a traditional web framework pattern. Catalyst follows this pattern and that encourages structured code.
Catalyst provides implicit routing + Controllers, Models and Views.
Dancer2 provides routing and controllers in the same classes.

This prototype implements a controller system where instead of the D2 route being defined as:

```perl
package My::App::Routes;
use Dancer2;

get '/' => sub {
    # a lot of complex route code here
};
```

it becomes becomes:
```perl
package My::App::Routes;
use Dancer2x::Tango;
get '/' => to('controller#action');
```

The Dancer2 module now no longer contains any business logic and so routing and controllers are separate.

`Dancer2x::Tango::to()` will then effectively wrap and call `My::App::Controller::Root->new->method($dsl)`

DSL
---

Dancer2 has its own mini language, the DSL, which provides keywords like `get`, `post`, `session`, `template`, etc.
This can make small webapps fun and easy to deploy.

However, as the app grows larger, these exports can conflict with other exports and it can be a pain to have to turn off specific exports.

Additionally, any code that must use the DSL must be within the Dancer2 module.
Except this turns out to not be exactly true, since `dsl` is also a keyword.

So it is possible to use all the DSL keywords as methods on the DSL object.
This also means the callback given to `get '/' => callback` can exist in a different package(the controller class) and still have access to the D2 stuff.

Controller Classes
------------------

This experiment moves the business logic to named subroutines in a controller class.
This makes it easier (subjective) to have smaller controller classes.

As a side benefit, because we're now using named subroutines, Devel::Cover can correctly handle coverage and perlcritic complexity rules won't throw a fit about package level complexity.
