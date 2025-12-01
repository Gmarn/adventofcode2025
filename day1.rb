#!/usr/bin/env ruby
# frozen_string_literal: true

# Advent of Code 2025 - Day 1: Secret Entrance

class DialSafe
  DIAL_SIZE = 100
  START_POSITION = 50

  def initialize(instructions)
    @instructions = instructions
    @position = START_POSITION
    @zero_count = 0
  end

  def solve(debug: false)
    puts "Starting position: #{@position}" if debug

    @instructions.each_with_index do |instruction, index|
      direction = instruction[0]
      distance = instruction[1..].to_i

      @position = if direction == 'R'
                    (@position + distance) % DIAL_SIZE
                  else # direction == 'L'
                    (@position - distance) % DIAL_SIZE
                  end

      if debug
        puts "#{index + 1}. #{instruction} -> position #{@position}"
      end

      if @position.zero?
        @zero_count += 1
        puts "   *** Landed on 0! Count: #{@zero_count}" if debug
      end
    end

    @zero_count
  end

  def solve_part2(debug: false)
    puts "Starting position: #{@position}" if debug

    @instructions.each_with_index do |instruction, index|
      direction = instruction[0]
      distance = instruction[1..].to_i

      # Count how many times we pass through 0 during this rotation
      clicks_through_zero = count_zeros_in_rotation(@position, direction, distance)
      @zero_count += clicks_through_zero

      # Update position
      @position = if direction == 'R'
                    (@position + distance) % DIAL_SIZE
                  else # direction == 'L'
                    (@position - distance) % DIAL_SIZE
                  end

      if debug
        if clicks_through_zero > 0
          puts "#{index + 1}. #{instruction} -> position #{@position} (passed through 0: #{clicks_through_zero} times)"
          puts "   *** Total count: #{@zero_count}"
        else
          puts "#{index + 1}. #{instruction} -> position #{@position}"
        end
      end
    end

    @zero_count
  end

  private

  def count_zeros_in_rotation(start_pos, direction, distance)
    # If distance is 0, we don't move
    return 0 if distance.zero?

    if direction == 'R'
      # Moving right (toward higher numbers)
      # We click through positions: start_pos+1, start_pos+2, ..., start_pos+distance
      # Count how many of these are ≡ 0 (mod 100)

      # First zero we encounter is at position 0
      # From start_pos, how many clicks to reach 0?
      if start_pos == 0
        # Next 0 is 100 clicks away
        first_zero_at = DIAL_SIZE
      else
        # We reach 0 at click: 100 - start_pos
        first_zero_at = DIAL_SIZE - start_pos
      end

      # If we don't reach the first zero, count is 0
      return 0 if first_zero_at > distance

      # After first zero, we hit 0 every 100 clicks
      # Count: 1 (for first) + how many more complete cycles fit in remaining distance
      remaining_after_first = distance - first_zero_at
      additional_zeros = remaining_after_first / DIAL_SIZE

      1 + additional_zeros

    else # direction == 'L'
      # Moving left (toward lower numbers)
      # We click through positions: start_pos-1, start_pos-2, ..., start_pos-distance
      # Count how many of these are ≡ 0 (mod 100)

      # From start_pos, how many clicks to reach 0?
      if start_pos == 0
        # Next 0 is 100 clicks away
        first_zero_at = DIAL_SIZE
      else
        # We reach 0 after start_pos clicks
        first_zero_at = start_pos
      end

      # If we don't reach the first zero, count is 0
      return 0 if first_zero_at > distance

      # After first zero, we hit 0 every 100 clicks
      remaining_after_first = distance - first_zero_at
      additional_zeros = remaining_after_first / DIAL_SIZE

      1 + additional_zeros
    end
  end
end

# Parse command line arguments
mode = ARGV[0] || 'example'
part = ARGV[1] || '1'

case mode
when 'example'
  # Example from the puzzle
  example = %w[L68 L30 R48 L5 R60 L55 L1 L99 R14 L82]

  if part == '1'
    puts "--- Example Trace (Part 1) ---"
    safe = DialSafe.new(example)
    result = safe.solve(debug: true)

    puts "\nExample result: #{result} (expected: 3)"
    puts result == 3 ? "✓ Example passed!" : "✗ Example failed!"
  else
    puts "--- Example Trace (Part 2) ---"
    safe = DialSafe.new(example)
    result = safe.solve_part2(debug: true)

    puts "\nExample result: #{result} (expected: 6)"
    puts result == 6 ? "✓ Example passed!" : "✗ Example failed!"
  end

when 'input'
  # Read from input file
  instructions = File.readlines('input-day1.txt', chomp: true)

  puts "--- Solving with input-day1.txt (#{instructions.count} instructions) ---"

  if part == '1'
    safe = DialSafe.new(instructions)
    result = safe.solve(debug: false)
    puts "\nPart 1: The password is #{result}"
  else
    safe = DialSafe.new(instructions)
    result = safe.solve_part2(debug: false)
    puts "\nPart 2: The password is #{result}"
  end

else
  puts "Usage: ruby day1.rb [example|input] [1|2]"
  puts "  Mode:"
  puts "    example - Run with the example from the puzzle (default)"
  puts "    input   - Run with input-day1.txt"
  puts "  Part:"
  puts "    1 - Count zeros at end of rotations only (default)"
  puts "    2 - Count all zeros during rotations (method 0x434C49434B)"
  exit 1
end
