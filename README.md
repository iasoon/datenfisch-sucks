# Datenfisch

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'datenfisch', :git => 'git://github.com/Iasoon/datenfisch.git'
```

And then execute:

    $ bundle

## Usage

I'll walk you through a simple use case.
Assume following models:

    User( name:String )
    Post( author:User, upvotes:Integer, contents:String )
    Comment( commenter:User, upvotes: Integer, contents:String )

Firstly, we'll set up providers. A provider is a wrapper around a database
table, where you describe how your data looks.

    PostFisch = Datenfisch.provider Post do
      stat :upvotes, sum(:upvotes)
      stat :count, count

      attr :user_id, :author_id
    end

    CommentFisch = Datenfisch.provider Comment do
      stat :upvotes, sum(:upvotes)
      stat :count, count

      attr :user_id, :commenter_id
    end

It's quite obvious what the `stat` method does. The `attr` method declares an
attribute alias. We'll see why this is useful later on.

In order to fetch these stats from the database, we can construct a query:

    query = Datenfisch.query.select(PostFisch.upvotes)

Just like ActiveRecord queries, these queries are composeable. In order to
execute them, you can call `run`, `to_a`, or enumerate them.

    query.where(author_id: 1).to_a

Now, for more exciting features. We'd like to combine stats, for example to get
a combined upvote count.

    upvotes = PostFisch.upvotes + CommentFisch.upvotes

In order to select a composite stat, we have to name it first.

    query = Datenfisch.query.select(upvotes.as('upvotes'))

This total value is quite boring. Obviously, we would like to know the total
upvote count per user. This is where the stat aliasing comes in handy.

    query.group(:user_id)

This alias will be substituted with the appropriate attribute for each
individual table.

We can also get ActiveRecord models from datenfisch queries

    users = Datenfisch.query.select(upvotes.as('upvotes')).model(User)

This will group records by `user_id`, join them with the `users` table, and
return `User` models decorated to contain the `upvotes` stat. An accessor will
be defined for all included stats.

    users.first.upvotes

It is useful to add Datenfich stats to ActiveRecord models.

    class User < ActiveRecord::Base
      ...
      extend Datenfisch::Model

      stat :upvotes, PostFisch.upvotes + CommentFisch.upvotes
    end

This will add the accessor `User.upvotes` to the `User` model. You can also
compute an `Users` upvotes with `user.upvotes`. This method also accepts optional
filter arguments, in the same way as provided to the `where` method.
Note that a stat added to a model is automatically aliased.

Finally, we get a handy method of fetching `User`s with added stats:

    User.with_stats(:upvotes)

This is a convenience method for

    Datenfisch.query.model(User).select(User.upvotes)

Note that both methods return a `Query` object, which you can extend with
additional query methods.

## Completeness

Datenfich currently forfills my own needs, but it is not very complete. If you
wish to use this library but need an additional feature, do not hesitate to drop
me an email. I will also happily accept pull requests.

## Contact
Please feel free to contact me with any questions, suggestions or complaints regarding
this library.
