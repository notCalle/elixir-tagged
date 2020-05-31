defmodule BinTree do
  use Tagged

  deftagged tree(left :: t(), right :: t())
  deftagged leaf(value :: term())
  deftagged nil, as: empty()

  @type t() :: tree() | leaf() | empty()

  defguard is_t(x) when is_tree(x) or is_leaf(x) or is_empty(x)

  @spec leaves(t()) :: [term()]
  def leaves(empty()), do: []
  def leaves(leaf(v)), do: [v]
  def leaves(tree(l, r)), do: leaves(l) ++ leaves(r)
end
