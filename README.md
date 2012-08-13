# Hamlbars

[![Build Status](https://secure.travis-ci.org/jamesotron/hamlbars.png?branch=master)](http://travis-ci.org/jamesotron/hamlbars)
[![Dependency Status](https://gemnasium.com/jamesotron/hamlbars.png)](https://gemnasium.com/jamesotron/hamlbars)

[Hamlbars](https://github.com/jamesotron/hamlbars) is a Ruby gem which allows
you to easily generate [Handlebars](http://handlebarsjs.com) templates using
[Haml](http://www.haml-lang.com).

# Installation

Add the following line to your Gemfile (on Rails, inside the `:assets` group):

```ruby
gem 'hamlbars', '~> 1.1'
```

If you are stuck with an older, yanked version like 2012.3.21 and it won't
update to 1.1, be sure to add `'~> 1.1'` as the version spec and run `bundle
install`.

# Demo Site

If you're unsure how all the pieces fit together then take a quick look at the
[demo site](http://hamlbars-demo.herokuapp.com/).

# Attribute bindings

You can easily add attribute bindings by adding a `:bind` hash to the tag
attributes, like so:

```haml
%div{ :class => 'widget', :bind => { :title => 'App.widgetController.title' }
```

Which will generate the following output:

```handlebars
<div class="widget" {{bindAttr title="App.widgetController.title"}}></div>
```

# Action handlers

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

# Event bindings (old syntax)

You can also add one or more event actions by adding an event hash or array of
event hashes to the tag options. This syntax is being deprecated in favor of
the newer `:_action` syntax described above.

```haml
%a{ :event => { :on => 'click', :action => 'clicked' } } Click
```

or

```haml
%div{ :events => [ { :on => 'mouseover', :action => 'highlightView' }, { :on => 'mouseout', :action => 'disableViewHighlight' } ] }
```

Note that the default event is `click`, so it's not necessary to specify it:

```haml
%a{ :event => { :action => 'clicked' } } Click
```

# Handlebars helper

You can use the `handlebars` helper (or just `hb` for short) to generate both
Handlebars blocks and expressions.

## Expressions

Generating Handlebars expressions is as simple as using the `handlebars` helper
and providing the expression as a string argument:

```haml
= hb 'App.widgetController.title'
```

which will will generate:

```handlebars
{{App.widgetController.title}}
```

## Blocks

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

## Options

The `hb` helper can take an optional hash of options which will be rendered
inside the expression:

```haml
= hb 'view App.InfoView', :tagName => 'span'
```

will result in:

```handlebars
{{view App.InfoView tagName="span"}}
```

## Tripple-stash

You can use the `handlebars!` or `hb!` variant of the `handlebars` helper to
output "tripple-stash" expressions within which Handlebars does not escape the
output.

# Configuring template output:

`hamlbars` has three configuration options, which pertain to the generated
JavaScript:

```ruby
Hamlbars::Template.template_destination    # default 'Handlebars.templates'
Hamlbars::Template.template_compiler       # default 'Handlebars.compile'
Hamlbars::Template.template_partial_method # default 'Handlebars.registerPartial'
```

These settings will work find by default if you are using Handlebars as a
standalone JavaScript library, however if you are using something that embeds
Handlebars within it then you'll have to change these.

If you're using [Ember.js](http://www.emberjs.com) then you can use:

```ruby
Hamlbars::Template.render_templates_for :ember
```

Which is effectively the same as:

```ruby
Hamlbars::Template.template_destination = 'Ember.TEMPLATES'
Hamlbars::Template.template_compiler = 'Ember.Handlebars.compile'
Hamlbars::Template.template_partial_method = 'Ember.Handlebars.registerPartial'
```

The good news is that if you're using the
[emberjs-rails](http://www.rubygems.org/gems/emberjs-rails) gem then it will
automatically detect hamlbars and change it for you. Magic!

If you're using [ember-rails](http://rubygems.org/gems/ember-rails) then you'll
need to put this in a initializer.

# Configuring JavaScript output:

Hamlbars has experimental support for template precompilation using
[ExecJS](http://rubygems.org/gems/execjs). To enable it, call

```ruby
Hamlbars::Template.enable_precompiler!
```

You can also disable enclosification (which is enabled by default) using:

```ruby
Hamlbars::Template.disable_closures!
```

# Asset pipeline

Hamlbars is specifically designed for use with Rails 3.1's asset pipeline.
Simply create templates ending in `.js.hamlbars` and Sprockets will know what
to do.

# Rails helpers

You can enable support by calling `Hamlbars::Template.enable_rails_helpers!`.
Probably the best way to do this is to create an initializer.  This is
dangerous and possibly stupid as a large number of Rails' helpers require
access to the request object, which is not present when compiling assets.

**Use at your own risk. You have been warned.**

# License and Copyright.

Hamlbars is Copyright &copy; 2012 [Sociable Limited](http://sociable.co.nz/)
and licensed under the terms of the MIT License.
