#!/usr/bin/env ruby
# frozen_string_literal: true

# Advent of Code 2025 - Day 2: Gift Shop

class GiftShop
  def self.invalid_id?(id, part: 1)
    if part == 1
      invalid_id_part1?(id)
    else
      invalid_id_part2?(id)
    end
  end

  def self.invalid_id_part1?(id)
    # Part 1: An ID is invalid if it's a sequence of digits repeated exactly twice
    # Examples: 55 (5 repeated), 6464 (64 repeated), 123123 (123 repeated)
    # No leading zeros allowed

    id_str = id.to_s

    # Must have even length to be repeatable
    return false if id_str.length.odd?

    # Split in half and check if both halves are equal
    mid = id_str.length / 2
    left_half = id_str[0...mid]
    right_half = id_str[mid..]

    # Check for leading zeros (invalid ID)
    return false if left_half[0] == '0'

    left_half == right_half
  end

  def self.invalid_id_part2?(id)
    # Part 2: An ID is invalid if it's made of some sequence repeated at least twice
    # Examples: 12341234 (1234 x 2), 123123123 (123 x 3), 1212121212 (12 x 5)
    # No leading zeros allowed

    id_str = id.to_s
    len = id_str.length

    # Check for leading zeros
    return false if id_str[0] == '0'

    # Try all possible pattern lengths (from 1 to len/2)
    # Pattern must repeat at least twice, so max pattern length is len/2
    (1..(len / 2)).each do |pattern_length|
      # Check if the length is divisible by pattern_length
      next unless len % pattern_length == 0

      # Extract the pattern
      pattern = id_str[0...pattern_length]

      # Check if the entire string is made of this pattern repeated
      num_repetitions = len / pattern_length
      if pattern * num_repetitions == id_str
        return true # Found a valid repeating pattern
      end
    end

    false
  end

  def self.find_invalid_ids_in_range(range_start, range_end, part: 1)
    invalid_ids = []

    (range_start..range_end).each do |id|
      invalid_ids << id if invalid_id?(id, part: part)
    end

    invalid_ids
  end

  def self.solve(ranges_str, part: 1, debug: false)
    # Parse ranges: "11-22,95-115,..."
    ranges = ranges_str.split(',').map do |range|
      parts = range.split('-')
      [parts[0].to_i, parts[1].to_i]
    end

    total_sum = 0
    all_invalid_ids = []

    ranges.each do |(start, finish)|
      invalid_ids = find_invalid_ids_in_range(start, finish, part: part)

      if debug && !invalid_ids.empty?
        puts "Range #{start}-#{finish}: #{invalid_ids.join(', ')}"
      end

      all_invalid_ids.concat(invalid_ids)
      total_sum += invalid_ids.sum
    end

    if debug
      puts "\nAll invalid IDs: #{all_invalid_ids.join(', ')}" if all_invalid_ids.length <= 20
      puts "Total count: #{all_invalid_ids.length}"
    end

    total_sum
  end
end

# Parse command line arguments
mode = ARGV[0] || 'example'
part = (ARGV[1] || '1').to_i

case mode
when 'example'
  # Example from the puzzle
  if part == 1
    example_ranges = '11-22,95-115,998-1012,1188511880-1188511890,222220-222224,446443-446449,38593856-38593862'
    expected = 1227775554
  else
    example_ranges = '11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124'
    expected = 4174379265
  end

  puts "--- Example (Day 2 Part #{part}) ---"
  result = GiftShop.solve(example_ranges, part: part, debug: true)

  puts "\nExample result: #{result} (expected: #{expected})"
  puts result == expected ? "✓ Example passed!" : "✗ Example failed!"

when 'input'
  # Read from input file
  ranges_str = File.read('input-day2.txt').strip

  puts "--- Solving with input-day2.txt (Part #{part}) ---"
  result = GiftShop.solve(ranges_str, part: part, debug: false)

  puts "\nPart #{part}: The sum is #{result}"

else
  puts "Usage: ruby day2.rb [example|input] [1|2]"
  puts "  Mode:"
  puts "    example - Run with the example from the puzzle (default)"
  puts "    input   - Run with input-day2.txt"
  puts "  Part:"
  puts "    1 - Pattern repeated exactly twice (default)"
  puts "    2 - Pattern repeated at least twice"
  exit 1
end
