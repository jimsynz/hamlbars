# Hamlbars

[![Build Status](https://secure.travis-ci.org/jamesotron/hamlbars.png?branch=master)](http://travis-ci.org/jamesotron/hamlbars)
[![Dependency Status](https://gemnasium.com/jamesotron/hamlbars.png)](https://gemnasium.com/jamesotron/hamlbars)

[Hamlbars](https://github.com/jamesotron/hamlbars) is a Ruby gem which allows
you to easily generate [Handlebars](http://handlebarsjs.com) templates using
[Haml](http://www.haml-lang.com).

*For an alternative to Hamlbars, also check out
[Emblem](https://github.com/machty/emblem.js), if you are using Ember.*

# Installation

Add the following line to your Gemfile (on Rails, inside the `:assets` group):

```ruby
gem 'hamlbars', '~> 2.1'
```

# DEPRECATION WARNING

As of version 2.0 Hamlbars simply outputs raw Handlebars templates, and you will need to
use the precompiler of your choice to compile the assets for your usage.

If you're using [Ember.js](http://emberjs.com) then you will need the
[ember-rails](http://rubygems.org/gems/ember-rails) gem. If you're just using
Handlebars templates on their own then you need to use
[handlebars_assets](http://rubygems.org/gems/handlebars_assets) to precompile
for your framework.

Be sure to take a look at Hamlbars' sister project
[FlavourSaver](http://rubygems.org/gems/flavour_saver) for pure-ruby server-side
rendering of Handlebars templates.

As of version 2.1 Hamlbars emits `bind-attr` instead of `bindAttr` for bound
element attributes. If you are running an older version of Ember, then keep
your Gemfile pinned to `~> 2.0` until you upgrade.

# Chaining compilation using the Rails asset pipeline

When using the `handlebars_assets` or `ember-rails` gems you need to add an
extra file extension so that the asset pipeline knows to take the output of
Hamlbars and send it into the template compiler of your choice.  Luckily
both gems register the `hbs` extension, so you can enable asset compilation
by setting `.js.hbs.hamlbars` as the file extension for your templates.

# Demo Site

If you're unsure how all the pieces fit together then take a quick look at the
[demo site](http://hamlbars-demo.herokuapp.com/).

# Handlebars extensions to Haml.

Hamlbars adds a couple of extensions to Haml in order to allow you to create
handlebars expressions in your templates.

## Handlebars helper

You can use the `handlebars` helper (or just `hb` for short) to generate both
Handlebars blocks and expressions.

### Expressions

Generating Handlebars expressions is as simple as using the `handlebars` helper
and providing the expression as a string argument:

```haml
= hb 'App.widgetController.title'
```

which will will generate:

```handlebars
{{App.widgetController.title}}
```

### Blocks

Whereas passing a block to the `handlebars` helper will create a Handlebars
block expression:

```haml
%ul.authors
= hb 'each authors' do
  %li<
    = succeed ',' do
      = hb 'lastName'
    = hb 'firstName'
```

will result in the following markup:

```handlebars
<ul class="authors">
   {{#each authors}}
     <li>{{lastName}}, {{firstName}}</li>
   {{/each}}
</ul>
```

### Options

The `hb` helper can take an optional hash of options which will be rendered
inside the expression:

```haml
= hb 'view App.InfoView', :tagName => 'span'
```

will result in:

```handlebars
{{view App.InfoView tagName="span"}}
```

### Tripple-stash

You can use the `handlebars!` or `hb!` variant of the `handlebars` helper to
output "tripple-stash" expressions within which Handlebars does not escape the
output.

### In-tag expressions

Unfortunately, (or fortunately) due to the nature of Haml, we can't put Handlebars
expressions in a tag definition, eg:

```handlebars
<{{tagName}}>
  My content
</{{tagName}}>
```

But we can allow you to put Handlebars expressions in to generate tag arguments by
adding a special `hb` attribute to your tags. For example:

```haml
%div{:hb => 'idHelper'}
```

Which would render the following:

```handlebars
<div {{idHelper}}></div>
```

If you need to place more than one expression inside your tag then you can pass an array
of expressions.

## Ember.js specific extensions

A large portion of the audience for Hamlbars is using it to generate templates for sites
using the Ember.js javascript framework.  We have added some special extra syntax to
cater for Ember's common idioms.

### Attribute bindings

You can easily add attribute bindings by adding a `:bind` hash to the tag
attributes, like so:

```haml
%div{ :class => 'widget', :bind => { :title => 'App.widgetController.title' }
```

Which will generate the following output:

```handlebars
<div class="widget" {{bindAttr title="App.widgetController.title"}}></div>
```

### Action handlers

To use Ember's `{{action}}` helper, set the `:_action` attribute, like so:

```haml
%a{ :_action => 'toggle' } Toggle
%a{ :_action => 'edit article on="doubleClick"' } Edit
```

This will generate:

```html
<a {{action toggle}}>Toggle</a>
<a {{action edit article on="doubleClick"}}>Edit</a>
```

Note that `:_action` has a leading underscore, to distinguish it from regular
HTML attributes (`<form action="...">`).

# Rails helpers

You can enable support by calling `Hamlbars::Template.enable_rails_helpers!`.
Probably the best way to do this is to create an initializer.  This is
dangerous and possibly stupid as a large number of Rails' helpers require
access to the request object, which is not present when compiling assets.

That said, it can be pretty handy to have access to the route helpers.

**Use at your own risk. You have been warned.**

# License and Copyright.

Hamlbars is Copyright &copy; 2012 [Sociable Limited](http://sociable.co.nz/)
and licensed under the terms of the MIT License.
