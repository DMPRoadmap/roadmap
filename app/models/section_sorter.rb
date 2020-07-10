# frozen_string_literal: true

# Private: Takes a list of Sections and sorts them in the correct display order based on
# the number, modifiable, and id attributes.
#
# Examples:
#
#   SectionSorter.new(*@phase.sections).sort! # => Array of sorted Sections
#
#
class SectionSorter

  ##
  # Access the array of Sections
  #
  # Returns Array
  attr_accessor :sections

  ##
  # Initialize a new SectionSorter
  #
  # sections - A set of Section records
  #
  def initialize(*sections)
    @sections = sections
  end

  # Re-order {#sections} into the correct order.
  #
  # Returns Array of Sections
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def sort!
    if all_sections_unmodifiable?
      sort_as_homogenous_group
    elsif all_sections_modifiable?
      sort_as_homogenous_group
    else
      # If there are duplicates in the #1 position
      if duplicate_number_values.include?(1)

        mod1 = sections.select { |section| section.modifiable? && section.number == 1 }

        # There should only be, if any, one prefixed modifiable Section
        prefix = mod1.shift

        # In the off-chance that there is more than one prefix Section, stick them
        # after the  unmodifiable block
        erratic = mod1

        # Collect the unmodifiable Section ids in the order the should be displayed
        unmodifiable = sections
                       .select(&:unmodifiable?)
                       .sort_by { |section| [section.number, section.id] }

        # Then any additional Sections that come after the main block...
        modifiable = sections
                     .select { |section| section.modifiable? && section.number > 1 }
                     .sort_by { |section| [section.number, section.id] }

        # Create one Array with all of the ids in the correct order.
        self.sections = [prefix] + unmodifiable + erratic + modifiable
      else
        prefix = sections.detect { |s| s.modifiable? && s.number == 1 }
        remaining_sections = sections - [prefix]
        unmodifiable = remaining_sections.select(&:unmodifiable?)
                                         .sort_by { |s| [s.number, s.id] }
        modifiable   = remaining_sections.select(&:modifiable?)
                                         .sort_by { |s| [s.number, s.id] }

        self.sections = [prefix] + unmodifiable + modifiable
      end
      sections.uniq.compact
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable

  private

  def modifiable_values
    @modifiable_values ||= sections.map(&:modifiable?).uniq
  end

  def number_values_with_count
    @number_values_with_count ||= begin
      hash = Hash.new { |h, key| h[key] = 0 }
      sections.map(&:number).each { |number| hash[number] += 1 }
      hash
    end
  end

  def duplicate_number_values
    @duplicate_number_values ||= number_values_with_count.select do |_number, count|
      count > 1
    end.keys
  end

  def all_sections_unmodifiable?
    modifiable_values == [false]
  end

  def all_sections_modifiable?
    modifiable_values == [true]
  end

  def sort_as_homogenous_group
    sections.sort_by { |section| [section.number, section.id] }
  end

end
