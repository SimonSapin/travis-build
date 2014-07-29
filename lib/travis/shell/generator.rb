module Travis
  module Shell
    class Generator
      attr_reader :nodes, :level

      def initialize(nodes)
        @nodes = nodes
        @level = 0
      end

      def generate
        lines = handle(nodes).flatten
        script = lines.join("\n").strip
        script = unindent(script)
        script = normalize_newlines(script)
        script
      end

      private

        def handle(node)
          node = node.dup
          type = node.shift
          send(:"handle_#{type}", *node)
        end

        def handle_script(nodes)
          nodes.map { |node|  handle(node) }
        end

        def handle_cmds(nodes)
          indent { handle_script(nodes) }
        end

        def indent(lines = nil)
          @level += 1
          lines = Array(lines || yield).flatten.map { |line| "  #{line}" }
          @level -= 1
          lines
        end

        def unindent(string)
          string.gsub /^#{string[/\A\s*/]}/, ''
        end

        def normalize_newlines(string)
          string.gsub("\n\n\n", "\n\n")
        end

        def with_margin
          code = []
          code << '' if level == 0
          code << yield
          code << '' if level == 0
          code
        end
    end
  end
end