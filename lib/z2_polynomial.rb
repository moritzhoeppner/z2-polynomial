class Z2Polynomial < Array
  class << self
    def from_hexstr(hexstr)
      pol = Z2Polynomial.new
      hexstr.chars.each do |c|
        pol.concat(
          Integer("0x#{c}") # to integer
            .to_s(2)        # to string as base 2
            .rjust(4, '0')  # pad with zeroes to length 4
            .chars          # get the 4 bits
            .map(&:to_i)    # convert them to an array of integers
        )
      end
      pol.cap
    end
  end

  def to_hexstr
    # Add leading zeroes so that self has complete 4-bit slices.
    incomplete_slice_length = self.length % 4
    padded = if incomplete_slice_length == 0
        self
      else
        self.pad_to_length(self.length + 4 - incomplete_slice_length)
      end
    
    hexstr = ''

    padded.each_slice(4) do |four_bits|
      # Convert the 4-bit slice first to an integer, then to a hex string (1 character).
      int = 0
      4.times { |i| int += (four_bits[3 - i] || 0) * (2 ** i) }
      hexstr += int.to_s(16)
    end

    hexstr
  end

  def to_s
    return '0' if self.cap == [0]

    parts = self.cap.reverse.each_with_index.map do |coeff, exp|
      # Only display non-zero parts of the polynomial
      next if coeff == 0

      if exp == 0
        '1'
      elsif exp == 1
        'x'
      else
        "x^#{exp}"
      end
    end

    parts.compact.reverse.join(' + ')
  end

  def reverse
    Z2Polynomial.new(super)
  end

  def pad_to_length(length)
    Z2Polynomial.new([0] * (length - self.length) + self)
  end

  def cap
    capped = Z2Polynomial.new(self.drop_while { |c| c == 0 })
    capped == [] ? Z2Polynomial.new([0]) : capped
  end

  def deg
    self.cap.length - 1
  end

  def +(other)
    summand1, summand2 = pad_to_match(self, other)
    sum = Z2Polynomial.new
    summand1.length.times do |i|
      sum.concat([ summand1[i] ^ summand2[i] ])
    end
    sum.cap
  end

  def *(other)
    factor1, factor2 = pad_to_match(self, other)
    factor_length = factor1.length

    product = Z2Polynomial.new
    product_length = 2 * (factor1.length - 1) + 1
    
    product_length.times do |i|
      ith_coeff = 0
      (i + 1).times do |j|
        ith_coeff = ith_coeff ^ ((factor1[j] || 0) * (factor2[i - j] || 0))
      end
      product.concat([ith_coeff])
    end
    
    product.cap
  end

  def %(other)
    return self if self.deg < other.deg
    
    offset = Z2Polynomial.new(self.deg - other.deg, 0)
    rest = self + other.dup.concat(offset)

    (rest % other).cap
  end

  private

  def pad_to_match(pol1, pol2)
    longer, shorter = pol1.length >= pol2.length ? [pol1, pol2] : [pol2, pol1]
    [longer, shorter.pad_to_length(longer.length)]
  end
end
