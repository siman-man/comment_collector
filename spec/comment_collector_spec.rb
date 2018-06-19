RSpec.describe CommentCollector do
  describe '#comments' do
    it 'test case 1' do
      src = <<~SRC
        # this is comment.
        a = 1
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(1)

      comment = comments[0]
      expect(comment.first_lineno).to eq(0)
      expect(comment.first_column).to eq(0)
      expect(comment.last_lineno).to eq(0)
      expect(comment.last_column).to eq(18)
      expect(comment.value).to eq("# this is comment.\n")
    end

    it 'test case 2' do
      src = <<~SRC
        s = 'word'
        =begin
        hello world
        =end
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(1)

      comment = comments[0]
      expect(comment.first_lineno).to eq(1)
      expect(comment.first_column).to eq(0)
      expect(comment.last_lineno).to eq(3)
      expect(comment.last_column).to eq(4)
      expect(comment.value).to eq("=begin\nhello world\n=end\n")
    end

    it 'test case 3' do
      src = <<~SRC
        a = 1 # integer
        s = 'hello' # string
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(2)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(6)
      expect(comment1.last_lineno).to eq(0)
      expect(comment1.last_column).to eq(15)
      expect(comment1.value).to eq("# integer\n")

      comment2 = comments[1]
      expect(comment2.first_lineno).to eq(1)
      expect(comment2.first_column).to eq(12)
      expect(comment2.last_lineno).to eq(1)
      expect(comment2.last_column).to eq(20)
      expect(comment2.value).to eq("# string\n")
    end

    it 'test case 4' do
      src = <<~SRC
        # method
        # comment
        def say
          'hi'
        end
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(1)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(0)
      expect(comment1.last_lineno).to eq(1)
      expect(comment1.last_column).to eq(9)
      expect(comment1.value).to eq("# method\n# comment\n")
    end

    it 'test case 5' do
      src = <<~SRC
        # coding: utf-8

        # another comment
        def foo
        end
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(2)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(0)
      expect(comment1.last_lineno).to eq(0)
      expect(comment1.last_column).to eq(15)
      expect(comment1.value).to eq("# coding: utf-8\n")

      comment2 = comments[1]
      expect(comment2.first_lineno).to eq(2)
      expect(comment2.first_column).to eq(0)
      expect(comment2.last_lineno).to eq(2)
      expect(comment2.last_column).to eq(17)
      expect(comment2.value).to eq("# another comment\n")
    end

    it 'test case 6' do
      src = <<~SRC
        __END__
        # data1
        data2
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(0)
    end

    it 'test case 7' do
      src = <<~SRC
        # class comment
        class Foo
          BAR = 100 # value

          # line of comment
          @@test = 'test'

          # comment for method
          def baz
          end
        end
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(4)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(0)
      expect(comment1.last_lineno).to eq(0)
      expect(comment1.last_column).to eq(15)
      expect(comment1.value).to eq("# class comment\n")

      comment2 = comments[1]
      expect(comment2.first_lineno).to eq(2)
      expect(comment2.first_column).to eq(12)
      expect(comment2.last_lineno).to eq(2)
      expect(comment2.last_column).to eq(19)
      expect(comment2.value).to eq("# value\n")

      comment3 = comments[2]
      expect(comment3.first_lineno).to eq(4)
      expect(comment3.first_column).to eq(2)
      expect(comment3.last_lineno).to eq(4)
      expect(comment3.last_column).to eq(19)
      expect(comment3.value).to eq("# line of comment\n")

      comment4 = comments[3]
      expect(comment4.first_lineno).to eq(7)
      expect(comment4.first_column).to eq(2)
      expect(comment4.last_lineno).to eq(7)
      expect(comment4.last_column).to eq(22)
      expect(comment4.value).to eq("# comment for method\n")
    end

    it 'test case 8' do
      src = <<~SRC
        # class comment
        # this is sample
        class Foo
          # test
          a = 3
        end
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(2)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(0)
      expect(comment1.last_lineno).to eq(1)
      expect(comment1.last_column).to eq(16)
      expect(comment1.value).to eq("# class comment\n# this is sample\n")

      comment2 = comments[1]
      expect(comment2.first_lineno).to eq(3)
      expect(comment2.first_column).to eq(2)
      expect(comment2.last_lineno).to eq(3)
      expect(comment2.last_column).to eq(8)
      expect(comment2.value).to eq("# test\n")
    end

    it 'test case 9' do
      src = <<~SRC
        Foo.new.say #=> 'hi'
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(1)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(12)
      expect(comment1.last_lineno).to eq(0)
      expect(comment1.last_column).to eq(20)
      expect(comment1.value).to eq("#=> 'hi'\n")
    end

    it 'test case 10' do
      src = <<~SRC
        # encoding: utf-8
      SRC

      comments = CommentCollector.get(src)
      expect(comments.size).to eq(1)

      comment1 = comments[0]
      expect(comment1.first_lineno).to eq(0)
      expect(comment1.first_column).to eq(0)
      expect(comment1.last_lineno).to eq(0)
      expect(comment1.last_column).to eq(17)
      expect(comment1.value).to eq("# encoding: utf-8\n")
    end
  end
end
