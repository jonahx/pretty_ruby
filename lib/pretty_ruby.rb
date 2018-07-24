module PrettyRuby


  refine Numeric do
    def max(other)
      self >= other ? self : other
    end

    def min(other)
      self <= other ? self : other
    end

    def squared
      self * self
    end

    def doubled
      2 * self
    end
  end

  refine Symbol do
    def >>(next_proc)
      ->(x) { next_proc.to_proc.(self.to_proc.(x)) }
    end

    # Need to redefine here so it picks up the other refinements
    # They don't retroactively bubble up inheritance chains.
    # Eg, `scan(:max)` requires that Numeric has our refined `max` method
    #
    def to_proc
      ->(*args, &blk) do
        receiver = args.first
        if (blk)
          receiver.send(self, &blk)
        else
          args[0] = self
          receiver.send(*args)
        end
      end
    end
  end

  refine Proc do
    def >>(next_proc)
      ->(x) { next_proc.to_proc.(self.(x)) }
    end
  end

  refine Array do

    # TODO: avoid duplication with Enumerable?
    def to_proc
      fn = first.to_proc
      args = drop(1)
      # TODO: document better
      # handles stuff like
      # maxs = cols.map([:map, :to_s >> :size] >> :max)
      if args.first.is_a?(Proc)
        ->(x) { fn.(x, &args.first) }
      else
        ->(x) { fn.(x, *args) }
      end
    end

    def drop(n)
      n >= 0 ? super(n) : take([0, size+n].max)
    end

    def take(n)
      n >= 0 ? super(n) : drop([0, size+n].max)
    end

    def >>(other)
      ->(x) { other.to_proc.(to_proc.(x)) }
    end

    # def to_proc
    #   ArrayWithToProc.new(self).to_proc
    # end

    # Because Array has a custom implementation of map, instead of just mixing
    # in Enumerable, we need to refine its map separately, even though we use 
    # the same code.
    #
    def map(*args, &blk)
      blk = blk ? blk : args.to_proc
      super(&blk)
    end

    def tail
      drop(1)
    end

    def init
      drop(-1)
    end

    # TODO: reduce in place
    #
    def right_reduce(init = nil, sym = nil, &blk)
      reverse.reduce(init, sym, &blk)
    end

    # TODO: make in place
    #
    def rscan(fn = nil, &blk)
      reverse.scan(fn, &blk)
    end

    def scan(fn = nil, &blk)
      no_args = !fn && !blk
      return partial_seqs if no_args
      blk = fn ? fn.to_proc : blk
      self.drop(1).reduce([self.first]) do |m, x|
        m << blk.(m.last, x)
      end
    end

    def nesting_level
      0.step.find { |n| flatten(n).none?(Array) }
    end

    class NDimMatrix < Array

      module PrivateArray
        refine Array do
          using PrettyRuby

          def aligned_cols(col_maxs)
            nesting_level == 1 ?
              aligned_cols_2d(col_maxs) :
              map{ |x| x.aligned_cols(col_maxs) }
          end

          def aligned_cols_2d(col_widths)
            transpose.zip(col_widths).map do |col, width|
              col.map{ |x| sprintf("%#{width}s", x) } 
            end.transpose
          end

          def joined_records(nesting)
            nesting == 0 ?
              join('  ') :
              map{ |x| x.joined_records(nesting - 1) }.join("\n" * nesting)
          end
        end
      end

      using PrivateArray

      def to_s
        nest_lev = nesting_level
        matrix_2d = flatten(nest_lev - 1)
        cols = matrix_2d.transpose
        col_maxs = cols.map([:map, :to_s >> :size] >> :max)
        aligned_cols(col_maxs)
          .joined_records(nest_lev)
      end
    end

    def formatted_matrix
      # make ordinary arrays work without special casing them
      #
      matrix = nesting_level > 0 ? self : [self]
      NDimMatrix.new(matrix).to_s
    end

    private

    def partial_seqs
      self.drop(1).reduce([[self.first]]) do |m, x|
        m << m.last + [x]
      end
    end

  end

  #TODO: add separate tests for this
  refine ::Enumerable do

    def to_proc
      fn = first.to_proc
      args = drop(1)
      # TODO: document better
      # handles stuff like
      # maxs = cols.map([:map, :to_s >> :size] >> :max)
      if args.first.is_a?(Proc)
        ->(x) { fn.(x, &args.first) }
      else
        ->(x) { fn.(x, *args) }
      end
    end

    def map(*args, &blk)
      return super unless args_given?(args, blk)
      super(&smart_block(args, blk))
    end

    def max_by(*args, &blk)
      return super unless args_given?(args, blk)
      return super(args.first, &blk) if n_given?(args)
      super(&smart_block(args, blk))
    end

    def min_by(*args, &blk)
      return super unless args_given?(args, blk)
      return super(args.first, &blk) if n_given?(args)
      super(&smart_block(args, blk))
    end

    def sort_by(*args, &blk)
      return super unless args_given?(args, blk)
      super(&smart_block(args, blk))
    end

    private

    def args_given?(args, blk)
      blk || !args.empty?
    end

    def n_given?(args)
      args && args.first.is_a?(Integer)
    end

    def smart_block(args, blk) 
      blk ? blk : args.to_proc
    end
  end

  refine TrueClass do
    def to_i
      1
    end
  end

  refine FalseClass do
    def to_i
      0
    end
  end

end
