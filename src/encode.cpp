#include <boost/range/adaptors.hpp>
#include <boost/range/numeric.hpp>
#include <cyrillic-encoder/encode.hpp>

namespace cyr_enc {

std::string encode_string(
    std::string_view text,
    std::array<std::pair<char, std::string_view>, num_alphanumeric> const
        &conversion_table) {
  return boost::accumulate(text | boost::adaptors::transformed([&](char c) {
                             return encode_char(c, conversion_table);
                           }),
                           std::string{},
                           [](std::string sum, std::string_view const &piece) {
                             return sum.append(piece);
                           });
}

} // namespace cyr_enc
