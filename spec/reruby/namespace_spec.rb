require 'spec_helper'

describe Reruby::Namespace do

  def namespace(consts)
    Reruby::Namespace.new(consts)
  end

  describe "#can_resolve_to?" do

    it "knows that you can add arbitrary consts at the end of the external namespace" do
      usage_namespace = namespace(%w(A B C))
      definition_namespace = namespace(%w(A C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "knows that for full namespaces it doesn't matter the external/inline definition" do
      namespace1 = namespace(%w(A B C))
      namespace2 = namespace(%w(A B::C))

      expect(namespace1.can_resolve_to?(namespace2)).to be_truthy
    end

    it "knows that you can't add arbitrary consts in the middle of the inline namespace" do
      usage_namespace = namespace(%w(A::B::W::C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "knows that a more general path can't resolve to a more specific one" do
      usage_namespace = namespace(%w(A C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "knows that you can always resolve root consts inside any namespace" do
      usage_namespace = namespace(%w(A B C))
      definition_namespace = namespace(%w(C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy
    end

    it "doesn't resolve if the definition is root but on a inline ns " do
      usage_namespace = namespace(%w(J::A))
      definition_namespace = namespace(%w(A))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "doesn't resolve when all the consts in the definiton aren't there" do
      usage_namespace = namespace(%w(A J C))
      definition_namespace = namespace(%w(A B C))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_falsy
    end

    it "knows that 2 namespaces are equal so they resolve" do
      usage_namespace = namespace(%w(J::A))
      definition_namespace = namespace(%w(J::A))

      expect(usage_namespace.can_resolve_to?(definition_namespace)).to be_truthy

    end

  end

  describe "#nesting_level_in" do
    it "returns nil when they aren't nested" do
      one_ns = namespace(%w(Z::A))
      other_ns = namespace(%w(J::A))

      nesting_level = one_ns.nesting_level_in(other_ns)

      expect(nesting_level).to be_nil
    end

    it "returns the number of different consts" do
      one_ns = namespace(%w(Z::A))
      other_ns = namespace(%w(Z::A::B::C))

      nesting_level = other_ns.nesting_level_in(one_ns)

      expect(nesting_level).to eq 2

    end
  end

  describe "#relative_path" do
    it "returns the module as a unix path" do
      one_ns = namespace(%w(Some::ClassName))

      expected = "some/class_name.rb"

      expect(one_ns.relative_path).to eq(expected)
    end

  end

end
