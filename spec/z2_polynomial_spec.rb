require 'z2_polynomial'

describe Z2Polynomial do
  describe 'from_hexstr' do
    it 'returns an instance that represents the given number' do
      pol = Z2Polynomial.from_hexstr('0a') # 0000 1010
      expect(pol).to eq([1, 0, 1, 0])
      expect(pol).to be_a(Z2Polynomial)
    end
  end

  describe 'to_hexstr' do
    it 'returns a string with a hexadecimal representation of self' do
      pol = Z2Polynomial.from_hexstr('a0')
      expect(pol.to_hexstr).to eq('a0')
    end

    it 'adds missing leading zeroes' do
      pol = Z2Polynomial.new([1, 1, 0, 0, 0, 1, 0]) # 110 0010 = 0110 0010 = 0x62
      expect(pol.to_hexstr).to eq('62')
    end
  end

  describe 'to_s' do
    it 'returns a string representing self' do
      pol = Z2Polynomial.new([0, 1, 0, 1, 1])
      expect(pol.to_s).to eq('x^3 + x + 1')
    end
  end

  describe 'cap' do
    it 'returns an instance without leading zeroes without modifying self' do
      pol = Z2Polynomial.new([0, 1, 0, 1, 0, 0, 0])
      capped = pol.cap
      expect(capped).to eq([1, 0, 1, 0, 0, 0])
      expect(capped).to be_a(Z2Polynomial)
      expect(pol).to eq([0, 1, 0, 1, 0, 0, 0])
    end

    it 'keeps one zero for the zero polynomial' do
      expect(Z2Polynomial.new([0]).cap).to eq([0])
    end
  end

  describe 'deg' do
    it 'returns the degree of the polynomial' do
      expect(Z2Polynomial.new([0, 1, 0, 1, 0, 0, 0]).deg).to eq(5)
    end
  end

  describe '+' do
    it 'xors the entries and pads with zeroes at the beginning' do
      x = Z2Polynomial.from_hexstr('cc') # 1100 1100
      y = Z2Polynomial.from_hexstr('a')  # 1010
      sum = x + y
      expect(sum).to eq([1, 1, 0, 0, 0, 1, 1, 0])
      expect(sum).to be_a(Z2Polynomial)
    end
  end

  describe '*' do
    it 'returns the correct result' do
      x = Z2Polynomial.from_hexstr('5') # 0101 = x^2 + 1
      y = Z2Polynomial.from_hexstr('b') # 1011 = x^3 + x + 1
      product = x * y
      expect(product).to eq([1, 0, 0, 1, 1, 1]) # x^5 + x^2 + x + 1
      expect(product).to be_a(Z2Polynomial)
    end
  end

  describe '%' do
    it 'returns the correct result' do
      x = Z2Polynomial.from_hexstr('b') # 1011 = x^+3 + x + 1
      y = Z2Polynomial.from_hexstr('3') # 0011 = x + 1
      #   (x^3 + x + 1) / (x + 1) = x^2 + x
      # - (x^3 + x^2)
      #   -----------
      #          x^2 + x + 1
      #       - (x^2 + x)
      #         ------------
      #                    1
      remainder = x % y
      expect(remainder).to eq([1])
    end
  end
end
