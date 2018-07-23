require 'minitest/autorun'
require_relative '../lib/pretty_ruby'

describe 'TrueClass#to_i' do
  using PrettyRuby

  it "gets converts true to 1" do
    true.to_i.must_equal 1
  end
end

describe 'FalseClass#to_i' do
  using PrettyRuby

  it "gets converts true to 0" do
    false.to_i.must_equal 0
  end
end

describe 'Symbol#>>' do
  using PrettyRuby
  it 'chains symbol procs to create pipelines' do
    pipeline = :next >> :to_s
    pipeline.(1).must_equal '2'
  end
end

describe 'Enumerable' do

  using PrettyRuby

  describe "#max_by" do
    it "still works with no args" do
      enum = [1, 0, -3, -2].each
      enum.max_by.must_be_kind_of Enumerator
    end

    it "still works with a block" do
      enum = [1, 0, -3, -2].each
      enum.max_by { |x| x.abs }.must_equal(-3)
    end

    it "still works with a block and n" do
      enum = [1, 0, -3, -2].each
      enum.max_by(2) { |x| x.abs }.must_equal [-3, -2]
    end

    it "converts a symbol to a proc" do
      enum = [-3, 0, 1, 2].each
      enum.max_by(:squared).must_equal(-3)
    end

    it "converts a symbol with additional args to a proc" do
      enum = [ [1, 2], [2, 0], [2, 2] ].each
      enum.max_by(:reduce, :+).must_equal [2, 2]
    end
  end

  describe "#min_by" do
    it "still works with no args" do
      enum = [1, 0, -3, -2].each
      enum.min_by.must_be_kind_of Enumerator
    end

    it "still works with a block" do
      enum = [1, 0, -3, -2].each
      enum.min_by { |x| x.abs }.must_equal(0)
    end

    it "still works with a block and n" do
      enum = [1, 0, -3, -2].each
      enum.min_by(2) { |x| x.abs }.must_equal [0, 1]
    end

    it "converts a symbol to a proc" do
      enum = [-3, 0, 1, 2].each
      enum.min_by(:squared).must_equal(0)
    end

    it "converts a symbol with additional args to a proc" do
      enum = [ [1, 2], [2, 0], [2, 2] ].each
      enum.min_by(:reduce, :+).must_equal [2, 0]
    end
  end

  describe "#sort_by" do

    it "works with no args" do
      enum = [1, 0, -3, -2].each
      enum.sort_by.must_be_kind_of Enumerator
    end

    it "works with a block" do
      enum = [1, 0, -3, -2].each
      actual = enum.sort_by { |x| x.abs }
      actual.must_equal [0, 1, -2, -3]
    end

    it "converts a symbol to a proc" do
      enum = [-3, -2, 0, 1].each
      enum.sort_by(:abs).must_equal [0, 1, -2, -3]
    end

    it "converts a array to a proc" do
      enum = [-3, -2, 0, 1].each
      enum.sort_by(:**, 2).must_equal [0, 1, -2, -3]
    end
  end
end

describe 'Array' do
  before do
    @arr = [2, 3]
  end

  describe "without refinement" do
    describe "#map" do
      it "raises on naked symbols" do
        ->() { @arr.map(:next) }.must_raise ArgumentError
      end
    end

    describe "#drop" do
      it "raises on negative values" do
        ->() { @arr.drop(-2) }.must_raise ArgumentError
      end
    end
  end

  using PrettyRuby

  describe "#map" do

    it "converts a symbol to a proc" do
      @arr.map(:next).must_equal [3, 4]
    end

    it "converts a symbol with additional args to a proc" do
      @arr.map(:+, 2).must_equal [4, 5]
    end
  end

  describe "#tail" do
    it "works on arrays of size > 1" do
      [1, 2, 3].tail.must_equal [2, 3]
    end

    it "works on arrays of size 1" do
      [1].tail.must_equal []
    end

    it "works on empty arrays" do
      [].tail.must_equal []
    end
  end

  describe "#init" do
    it "works on arrays of size > 1" do
      [1, 2, 3].init.must_equal [1, 2]
    end

    it "works on arrays of size 1" do
      [1].init.must_equal []
    end

    it "works on empty arrays" do
      [].init.must_equal []
    end
  end

  describe "#scan" do
    before do
      @arr = [1, 2, 3]
    end

    describe "with no block" do
      it "returns an array of partial sequences" do
        @arr.scan.must_equal [[1], [1, 2], [1, 2, 3]]
      end
    end

    describe "with block" do
      it "reduces the partial sequences using the block" do
        result = @arr.scan { |a, b|  a + b}
        result.must_equal [1, 3, 6]
      end
    end

    describe "with a symbol argument" do
      it "reduces the partial sequences using symbol.to_proc" do
        @arr.scan(:+).must_equal [1, 3, 6]
        @arr.scan(:*).must_equal [1, 2, 6]
      end
    end
  end

  describe "#drop" do
    it "works normally on positive values" do
      @arr = (1..10).to_a
      @arr.drop(2).must_equal (3..10).to_a
    end
    it "removes from end on negative values" do
      @arr = (1..10).to_a
      @arr.drop(-2).must_equal (1..8).to_a
    end
  end

  describe "#take" do
    it "works normally on positive values" do
      @arr = (1..10).to_a
      @arr.take(2).must_equal (1..2).to_a
    end
    it "takes from end on negative values" do
      @arr = (1..10).to_a
      @arr.take(-2).must_equal (9..10).to_a
    end
  end

  describe "#to_proc" do
    it "treats head as method, tail as args" do
      @arr = (1..10).to_a
      [:join, '-'].to_proc.([1,2,3]).must_equal "1-2-3"
    end
  end

end

__END__

  refine Enumerable do

    def scan(&fn)
      self.drop(1).reduce([self.first]) do |m, x|
        m << fn.(m.last, x)
      end
    end

    def rotate_with_fill(n, fill: nil)
      fill_elms = [fill] * n.abs
      n >= 0 ? drop(n) + fill_elms : fill_elms + drop(n)
    end


    # make it recursive (tables, records)
    #
    def elmwise(*args)
      if (args[1].is_a?(Array))
        meth, data = args
      else
        meth, fn, *proc_args = args
        fn = fn.to_proc # in case it's a symbol
        # data = fn.(self, :abs)
        data = fn.(self, *proc_args)
      end

      return self.zip(data).map{|x,y| x.send(meth, y)}
    end


    def fn_table(fn, arr)
      self.product(arr).map{|pair| fn.(*pair)}.each_slice(arr.size).to_a
    end

    # TODO: override regular map? detect when to do this?
    def cmap(sym, *args, &blk)
      # self.map {|x| x.send(sym, *args, &blk)}
      fn = sym.to_proc
      self.map {|x| fn.(*args, x)}
    end

    # with_index is an anti-pattern
    def to_table
      # need to get colwidths
      # max_widths = self.map {|x| x.map(&:to_s >> :size).max }
      max_widths = self.cmap(:map, &:to_s >> :size).max
      max_widths.map.with_index {|w, i| self[i].map{|x| "%#{w}s" % x}}
        .cmap(:join, ' ').join("\n")
    end

    def >>(other)
      ->(x) { other.to_proc.(to_proc.(x)) }
    end

    def to_proc
      fn = first.to_proc
      args = drop(1)
      ->(x) { fn.(x, *args) }
    end

  end
end

#TODO move to enumerable
p [(1..10).to_a, (10..15).to_a].map(&[:rotate_with_fill, 3, {fill: 0}])

__END__

# TODO also test the other way, all combos
#
rotate_join =  [:rotate, -2] >> [:join, '-']
p rotate_join.((1..6).to_a)
# (1..6).rotate(-2).join('-')

p [1..6, 3..7].map{ |x| x.to_a.rotate(-2).join('-') }
p [1..6, 3..7].map(&:to_a >> [:rotate, -2] >> [:join, '-'])

# TODO final convenience
# p [%w[one two], %w[three four]].map(:join, '-')
p [%w[one two], %w[three four]].map(&[:join, '-'])
p [%w[one two], %w[three four]].map {|x| x.join('-')}

__END__

module Enumerable

  ORIG_GROUP_BY = instance_method(:group_by)

  def group_by(:keys_or_method, &blk)
    puts "Hi"
    return ORIG_GROUP_BY.bind(self).(&blk) if block_given?
    "no block"
  end

end



ends_with_dash = ->(x){!/-$/ =~ x}
doesnt_continue = ->(x){/-$/ !~ x}
shift_down = ->(x){x.rotate(-1, fill: 0)}

# TODO: make it work like this instead
shift_down = [:rotate, -1,  0]  # if you provide a third arg, that's the fill

lines.group_by(ends_with_dash >> :to_01 >> shift_down >> [:scan, :+])

lines.group_by(ends_with_dash >> :to_01 >> [:rotate, -1, {fill: 0}] >> [:scan, :+])

lines.group_by(
  doesnt_continue >> :to_01 >> [:rotate, -1, {fill: 0}] >> [:scan, :+]
).values


p [1,2,3,4].group_by {|i| i%2}

# # https://codegolf.stackexchange.com/questions/159624/add-rainbow-pairs/159675#159675
# half = arr.size / 2
# arr.take(half).elmwise(:+, [:take, -half] >> :reverse) + arr.drop(half).drop(-half)


__END__

class Numeric
  def mult(n)
    self * n
  end
end

p [-1,2,3].cmap(:abs)

p [1,2,3].elmwise(:+, :reverse)
p [1,-2,3].elmwise(:+, :cmap, :abs)
__END__

p [1,2,3].elmwise(:*, [-10,11,12])
p [1,-2,3].elmwise(:*, ->(x){x.abs})
# TODO: p [1,-2,3].elmwise(:*, :map, :mult, 3)
p [1,-2,3].elmwise(:*, :mult, 3)

# times = ->(factor, x){factor * x}.curry
# minus1 = ->(x){x - 1}
# scan = ->(fn, x){}.curry
# pipeline = times.(3) >> minus1
# puts pipeline.(9)


# p [1,2,3,4].scan(&:*)
# puts [1,2,3,4].fn_table(:*.to_proc, [2,3,10]).map{|x| x.join(' ')}.join("\n")
# p [1,2,3,4].fn_table(:*.to_proc, [2,3,10])
#
# Print text table
# puts (1..10).to_a.fn_table(:*.to_proc, (1..10).to_a).to_table


arr=%w[one two- three four- five- six seven]

# [1,2,3].elmwise(:+, :map, ->(x){1.0/x})
# [1,2,3].elmwise(:+, ->(arr){arr.map{|x| 1.0/x}})
