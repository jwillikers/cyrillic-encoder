#include <cyrillic-encoder/encode.hpp>

#include <array>
#include <string>
#include <string_view>
#include <utility>

#include <boost/range/adaptors.hpp>
#include <boost/range/numeric.hpp>

namespace cyr_enc {

std::string encode_string(
    std::string_view text,
    std::array<std::pair<char, std::string_view>, num_alphanumeric> const
        &conversion_table) {
  return boost::accumulate(text | boost::adaptors::transformed([&](char character) {
                             return encode_char(character, conversion_table);
                           }),
                           std::string{},
                           [](std::string sum, std::string_view const &piece) {
                             return sum.append(piece);
                           });
}

} // namespace cyr_enc
