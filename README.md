[![Build Status](https://travis-ci.org/siman-man/comment_collector.svg?branch=master)](https://travis-ci.org/siman-man/comment_collector)

# CommentCollector

Get source code comments of Ruby.


## Installation

Or install it yourself as:

```
$ gem install comment_collector
```

## Usage

`example.rb`

```ruby
# class comment
# this is sample
class Foo
  BAR = 'hello' # string

  # method
  def say
    'hi'
  end
end

=begin
multi line
comments
=end
```

`comment.rb`

```ruby
require 'comment_collector'

comments = CommentCollector.get(File.read('example.rb'))

puts '=' * 20

comments.each do |comment|
  puts comment.value
  puts '=' * 20
end
```

result

```
$ ruby comment.rb
====================
# class comment
# this is sample
====================
# string
====================
# method
====================
=begin
multi line
comments
=end
====================
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CommentCollector project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/comment_collector/blob/master/CODE_OF_CONDUCT.md).
