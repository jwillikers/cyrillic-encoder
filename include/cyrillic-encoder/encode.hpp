#pragma once
#include <algorithm>
#include <array>
#include <cyrillic-encoder/export.h>
#include <iterator>
#include <string>
#include <string_view>
#include <utility>

namespace cyr_enc {

static constexpr unsigned num_alphanumeric{62};

// This is a sample table for converting all alphanumeric characters.
// Each character maps to a unique Cyrillic symbol.
// Uppercase and lowercase characters map to different symbols.
static constexpr std::array<std::pair<char, std::string_view>, num_alphanumeric>
    sample_conversion_table{{
        {'0', {"Ѐ"}}, {'1', {"Ё"}}, {'2', {"Ђ"}}, {'3', {"Ѓ"}}, {'4', {"Є"}},
        {'5', {"Ѕ"}}, {'6', {"І"}}, {'7', {"Ї"}}, {'8', {"Ј"}}, {'9', {"Љ"}},
        {'A', {"Њ"}}, {'B', {"Ћ"}}, {'C', {"Ќ"}}, {'D', {"Ѝ"}}, {'E', {"Ў"}},
        {'F', {"Џ"}}, {'G', {"А"}}, {'H', {"Б"}}, {'I', {"В"}}, {'J', {"Ѯ"}},
        {'K', {"Ѽ"}}, {'L', {"Д"}}, {'M', {"Е"}}, {'N', {"Ж"}}, {'O', {"З"}},
        {'P', {"И"}}, {'Q', {"Й"}}, {'R', {"К"}}, {'S', {"Л"}}, {'T', {"М"}},
        {'U', {"Н"}}, {'V', {"О"}}, {'W', {"П"}}, {'X', {"а"}}, {'Y', {"б"}},
        {'Z', {"в"}}, {'a', {"г"}}, {'b', {"д"}}, {'c', {"е"}}, {'d', {"ж"}},
        {'e', {"з"}}, {'f', {"и"}}, {'g', {"й"}}, {'h', {"к"}}, {'i', {"л"}},
        {'j', {"м"}}, {'k', {"н"}}, {'l', {"о"}}, {'m', {"п"}}, {'n', {"р"}},
        {'o', {"с"}}, {'p', {"т"}}, {'q', {"у"}}, {'r', {"ф"}}, {'s', {"х"}},
        {'t', {"ц"}}, {'u', {"ч"}}, {'v', {"ш"}}, {'w', {"щ"}}, {'x', {"ъ"}},
        {'y', {"ы"}}, {'z', {"ь"}},
    }};

// Encode the given character according to the conversion table.
// If the character is not in the table, an empty string view is returned.
// Currently, the conversion table must be sorted by key.
/* constexpr */ std::string_view encode_char(
    char c,
    std::array<std::pair<char, std::string_view>, num_alphanumeric> const
        &conversion_table = sample_conversion_table) {
  // This implementation uses a binary search to locate the character mapping.
  // This isn't necessary for the limited size of the sample table.
  // However, it scales better.
  // A compile-time hash map would make much more sense and not require sorting.
  auto const *found = std::lower_bound(
      std::begin(conversion_table), std::end(conversion_table), c,
      [](auto const &pair, char ch) { return std::get<0>(pair) < ch; });
  if (found == std::end(conversion_table) || std::get<0>(*found) != c) {
    return {};
  }
  return std::get<1>(*found);
}

// Encode each character in the given string according to the conversion table.
// Characters which do not exist in the table are ignored.
// The output will not contain them.
// Currently, the conversion table must be sorted by key.
// todo Generalize the interface here by using a C++20 range for the conversion
// table.
CYRILLIC_ENCODER_ENCODE_EXPORT std::string encode_string(
    std::string_view text,
    std::array<std::pair<char, std::string_view>, num_alphanumeric> const
        &conversion_table = sample_conversion_table);

} // namespace cyr_enc
