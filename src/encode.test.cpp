#include <boost/range/adaptors.hpp>
#include <boost/range/algorithm_ext.hpp>
#include <boost/ut.hpp>
#include <cyrillic-encoder/encode.hpp>
#include <string_view>

int main() {
  using namespace boost::ut;

  [[maybe_unused]] suite const encode_char = [] {
    "should_return_an_empty_string_given_null"_test = [] {
      static constexpr char input{'\0'};
      expect(std::empty(cyr_enc::encode_char(input)));
    };

    "should_return_a_different_cyrillic_symbol_for_each_case_of_the_letter_a"_test =
        [] {
          static constexpr char lowercase{'a'};
          static constexpr char uppercase{'A'};
          static constexpr std::string_view encoded_lowercase{"г"};
          static constexpr std::string_view encoded_uppercase{"Њ"};
          expect(encoded_lowercase == cyr_enc::encode_char(lowercase));
          expect(encoded_uppercase == cyr_enc::encode_char(uppercase));
        };

    "should_return_the_same_cyrillic_symbol_for_the_letter_a"_test = [] {
      static constexpr char input{'a'};
      static constexpr std::string_view encoded{"г"};
      expect(encoded == cyr_enc::encode_char(input));
      // Encode the letter 'a' twice to verify that the output is deterministic.
      expect(encoded == cyr_enc::encode_char(input));
    };

    "should_return_an_empty_string_for_a_non_alphanumeric_character"_test = [] {
      static constexpr char input{'\t'};
      expect(std::empty(cyr_enc::encode_char(input)));
    };

//    "should_encode_character_at_compile_time"_test = [] {
//      static constexpr char input{'V'};
//      static constexpr std::string_view encoded{"О"};
//      expect(constant<encoded.compare(cyr_enc::encode_char(input)) == 0>);
//    };
  };

  [[maybe_unused]] suite const encode_string = [] {
    "should_return_an_empty_string_given_empty_input"_test = [] {
      expect(std::empty(cyr_enc::encode_string(std::string_view{})));
    };

    "should_return_a_different_cyrillic_symbol_for_each_case_of_the_letter_a"_test =
        [] {
          static constexpr char lowercase{'a'};
          static constexpr char uppercase{'A'};
          static constexpr std::string_view encoded_lowercase{"г"};
          static constexpr std::string_view encoded_uppercase{"Њ"};
          expect(encoded_lowercase == cyr_enc::encode_char(lowercase));
          expect(encoded_uppercase == cyr_enc::encode_char(uppercase));
        };

    "should_return_an_empty_string_for_non_alphanumeric_input"_test = [] {
      static constexpr std::string_view input{"!?!"};
      expect(std::empty(cyr_enc::encode_string(input)));
    };

    "should_return_the_same_cyrillic_symbol_for_a_character"_test = [] {
      static constexpr std::string_view input{"aa"};
      static constexpr std::string_view encoded{"гг"};
      expect(encoded == cyr_enc::encode_string(input));
    };

    "should_encode_the_alphanumeric_characters_in_the_string_hello_world"_test =
        [] {
          static constexpr std::string_view input{"Hello, World!"};
          static constexpr std::string_view encoded{"БзоосПсфож"};
          expect(encoded == cyr_enc::encode_string(input));
        };

    "should_encode_each_alphanumeric_character_in_the_input"_test = [] {
      static constexpr std::string_view input{
          "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"};
      static constexpr std::string_view encoded{
          "ЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВѮѼДЕЖЗИЙКЛМНОПабвгдежзийклмнопрстуфхцчшщъы"
          "ь"};
      expect(encoded == cyr_enc::encode_string(input));
    };
  };

  [[maybe_unused]] suite const sample_table = [] {
    "should_contain_unique_keys"_test = [] {
      expect(std::size(cyr_enc::sample_conversion_table) ==
             boost::size(cyr_enc::sample_conversion_table |
                         boost::adaptors::map_keys | boost::adaptors::uniqued));
    };

    "should_contain_unique_values"_test = [] {
      expect(std::size(cyr_enc::sample_conversion_table) ==
             boost::size(cyr_enc::sample_conversion_table |
                         boost::adaptors::map_values |
                         boost::adaptors::uniqued));
    };

    "should_be_sorted_by_keys"_test = [] {
      expect(boost::is_sorted(cyr_enc::sample_conversion_table |
                              boost::adaptors::map_keys));
    };
  };
}
