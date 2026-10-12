"""Regression cases for excluding fenced code from documentation checks."""
import unittest

from check_docs import anchors, prose


class FenceTests(unittest.TestCase):
    def test_malformed_closer_does_not_hide_later_prose(self):
        text = 'Before\n```\n```not-a-close\n[code](missing.md)\n```\n[prose](real.md)\n'
        self.assertEqual(prose(text), 'Before\n\n[prose](real.md)\n')

    def test_only_matching_long_enough_closers_end_a_block(self):
        for opener in ['```', '````', '~~~', '~~~~']:
            for closer in [opener, opener + opener[0], '   ' + opener + ' \t']:
                with self.subTest(opener=opener, closer=closer):
                    wrong = '~~~' if opener[0] == '`' else '```'
                    text = opener + '\n' + wrong + '\n' + opener[:-1] + '\n'
                    text += opener + 'suffix\n# hidden\n' + closer + '\n# visible\n'
                    self.assertEqual(anchors(text), {'visible'})

    def test_indented_fence_with_info_and_crlf(self):
        self.assertEqual(prose('   ```python\r\n# hidden\r\n   ````\t\r\n# visible\r\n'),
                         '\n# visible\r\n')

    def test_unclosed_fence_extends_to_end(self):
        self.assertEqual(prose('Before\n~~~\n[code](missing.md)\n'), 'Before\n\n')

    def test_backtick_info_cannot_contain_backticks(self):
        text = '```bad`info\n[prose](real.md)\n'
        self.assertEqual(prose(text), text)


if __name__ == '__main__':
    unittest.main()
