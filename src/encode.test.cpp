#include <cyrillic-encoder/encode.hpp>
#include <boost/ut.hpp>
#include <string_view>

namespace test {

using namespace boost::ut;

suite encode_char = [] {

  "should_return_an_empty_string_given_null"_test = [] {
    static constexpr char input{'\0'};
    expect(std::empty(cyr_enc::encode_char(input)));
  };

  "should_return_a_different_cyrillic_string_for_each_case_of_a_character"_test = [] {
    static constexpr char lowercase{'a'};
    static constexpr char uppercase{'A'};
    static constexpr std::string_view encoded_lowercase{"г"};
    static constexpr std::string_view encoded_uppercase{"Њ"};
    expect(encoded_lowercase == cyr_enc::encode_char(lowercase));
    expect(encoded_uppercase == cyr_enc::encode_char(uppercase));
  };

  "should_return_the_same_cyrillic_string_for_a_character"_test = [] {
    static constexpr char input{'a'};
    static constexpr std::string_view encoded{"г"};
    expect(encoded == cyr_enc::encode_char(input));
  };

//  "should_return_unique_values_for_each_alphanumeric_character"_test = [] {
//    static constexpr std::array<char, 62> alphanumeric_characters{{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'}};
//    expect(boost::size(cyr_enc::sample_conversion_table | boost::adaptors::map_keys | boost::adaptors::uniqued) == cyr_enc::num_alphanumeric);
//  };

  "should_return_an_empty_string_for_a_non_alphanumeric_character"_test = [] {
  static constexpr char input{'\t'};
  expect(std::empty(cyr_enc::encode_char(input)));
  };

};

suite encode_string = [] {

  "should_return_an_empty_string_for_a_non_alphanumeric_characters"_test = [] {
    static constexpr std::string_view input{"!?!"};
    expect(std::empty(cyr_enc::encode_string(input)));
  };

  "should_return_the_same_cyrillic_string_for_a_character"_test = [] {
    static constexpr std::string_view input{"aa"};
    static constexpr std::string_view encoded{"гг"};
    expect(encoded == cyr_enc::encode_string(input));
  };

  // todo More tests.

};

}

int main() {}
