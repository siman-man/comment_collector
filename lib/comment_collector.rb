require 'comment_collector/version'

class CommentCollector
  Comment = Struct.new(:value, :first_lineno, :first_column, :last_lineno, :last_column)

  def self.get(src)
    new(src).comments
  end

  def initialize(src)
    @last_of_lines = Array.new(src.lines.size, 0)
    @exists_any_node = Array.new(src.lines.size, false)
    @end_of_lines = src.lines.map { |l| l.size - 1 } # for 0-index
    @src = src

    traverse(RubyVM::AST.parse(src))
  end

  def comments
    return @_comments if defined?(@_comments)
    comments = []
    value = ''
    multi_line_comment_f = false
    first_lineno = -1
    first_column = -1
    last_lineno = -1

    @src.lines.each_with_index do |line, lineno|
      sp = @last_of_lines[lineno]
      l = line[sp..]

      break if line.start_with?('__END__')

      if l =~ /^\s*#/
        if value.empty?
          first_lineno = lineno
          first_column = sp + l.index('#')
          value = l.lstrip
        elsif sp.zero?
          value += l
        else
          comments << Comment.new(value, first_lineno, first_column, last_lineno, @end_of_lines[last_lineno])
          first_lineno = lineno
          first_column = sp + l.index('#')
          value = l.lstrip
        end

        last_lineno = lineno
      elsif l =~ /^=begin/
        value = l
        first_lineno = lineno
        first_column = 0
        multi_line_comment_f = true
      elsif l =~ /^=end/
        value += l
        comments << Comment.new(value, first_lineno, first_column, lineno, @end_of_lines[lineno])
        value = ''
        multi_line_comment_f = false
      elsif multi_line_comment_f
        value += l
      elsif !value.empty? && (line =~ /^\s+$/ || @exists_any_node[lineno])
        comments << Comment.new(value, first_lineno, first_column, last_lineno, @end_of_lines[last_lineno])
        value = ''
      end
    end

    unless value.empty?
      comments << Comment.new(value, first_lineno, first_column, last_lineno, @end_of_lines[last_lineno])
    end

    @_comments = comments
  end

  private

  def traverse(parent)
    if parent.type != 'NODE_SCOPE'
      first_lineno = parent.first_lineno - 1
      first_column = parent.first_column
      last_lineno = parent.last_lineno - 1
      last_column = parent.last_column

      @last_of_lines[first_lineno] = [@last_of_lines[first_lineno], first_column].max
      @last_of_lines[last_lineno] = [@last_of_lines[last_lineno], last_column].max
      @exists_any_node[first_lineno] = @exists_any_node[last_lineno] = true
    end

    parent.children.compact.each do |child|
      traverse(child)
    end
  end
end
