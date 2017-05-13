module Reruby
  class InlineConsts

    attr_reader :nodes_in_order

    def self.from_node_tree(node_tree)
      nodes_in_order = reverse_const_tree(node_tree)
      new(nodes_in_order)
    end

    def each_sub
      seen_consts = []
      nodes_in_order.each do |node|
        seen_consts.push(node)
        inline_until_me = InlineConsts.new(seen_consts)
        yield(inline_until_me)
      end
    end

    def as_namespace
      if forced_root?
        Namespace::Root.new(const_names)
      else
        Namespace::Absolute.new(const_names)
      end
    end

    def as_source
      const_names = nodes_in_order.map do |node|
        node.loc.name.source
      end

      const_names.join("::")
    end

    def last_node
      nodes_in_order.last
    end

    private

    def initialize(nodes_in_order)
      @nodes_in_order = nodes_in_order
    end

    def self.reverse_const_tree(node)
      next_node, _ = node.children

      if next_node
        reverse_const_tree(next_node) + [node]
      else
        [node]
      end
    end

    def forced_root?
      nodes_in_order.first.type == :cbase
    end

    def const_names
      if forced_root?
        name_nodes = nodes_in_order.slice(1 .. -1)
      else
        name_nodes = nodes_in_order
      end
      name_nodes.map { |node| node.loc.name.source }
    end

  end
end
