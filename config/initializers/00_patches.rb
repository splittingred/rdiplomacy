# frozen_string_literal: true

module Enumerable
  def max_by_all
    return each unless block_given?
    last_yield = nil
    each_with_object([]) do |e,a|
      ye = yield(e)
      case last_yield.nil? ? -1 : last_yield <=> ye
      when -1
        a.replace([e])
        last_yield = ye
      when 0
        a << e
      else
        # do nothing
      end
    end
  end
end
