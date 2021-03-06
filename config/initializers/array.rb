class Array
  # Matches elements of a to elements of b and passes each pair to a block.
  # If an element of a has no match in b or vice versa, nil is passed.
  # Assumes no duplicates in either array.
  def compare_by_element(arr, hashfunc = nil, &block)
    hashfunc ||= Proc.new{|x| x}
    
    # create hashes from a and b. can have multiple elements per key
    ah = {}; self.each{|x| key = hashfunc.call(x); (ah[key] ||= []) << x}
    bh = {}; arr.each{|x| key = hashfunc.call(x); (bh[key] ||= []) << x}
    
    # matches: loop over a's elements, find them in b, yield, remove from both hashes
    self.each do |x|
      key = hashfunc.call(x)
      if hit = bh[key] and !hit.empty?
        block.call(x, hit.first) 
        ah[key].shift
        bh[key].shift
      end
    end
    
    # a-only's: loop over ah's remaining elements. these had no match in b.
    ah.values.flatten.each{|x| block.call(x, nil)}
    
    # b-only's: loop over bh's remaining elements. these had no match in a.
    bh.values.flatten.each{|x| block.call(nil, x)}
    
    nil
  end
end