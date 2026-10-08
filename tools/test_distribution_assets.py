"""Offline distribution guard regression tests. Run with unittest discover."""
import os
from pathlib import Path
import unittest

import package
from distribution_assets import ARTWORK, PNG, audit_assets

ROOT = Path(__file__).resolve().parents[1]


class DistributionAssetsTest(unittest.TestCase):
    def rejected(self, path, data):
        with self.assertRaises(ValueError):
            audit_assets({path: data})

    def test_reviewed_project_artwork(self):
        audit_assets({name: (ROOT / name).read_bytes() for name in ARTWORK})

    def test_cache_paths(self):
        for name in ('layer/marker-icons/a.png', 'layer\\MARKER-ICONS\\a.png'):
            with self.subTest(name=name):
                self.rejected(name, b'local')

    def test_marker_names_outside_cache(self):
        for name in ('stun-hammer.png', 'aim-radish.png', 'touch-switch.png', 'touch-coin.png'):
            self.rejected('docs/' + name, b'local')

    def test_renamed_image(self):
        self.rejected('docs/unknown.png', (ROOT / next(iter(ARTWORK))).read_bytes())

    def test_replaced_approved_image(self):
        self.rejected(next(iter(ARTWORK)), b'replacement')

    def test_disguised_binary(self):
        self.rejected('docs/readme.txt', b'FRES\0model data')

    def test_game_containers_and_code(self):
        for ext in ('szs', 'sarc', 'bfres', 'bflim', 'rpx', 'rpl', 'wud', 'wux', 'bin', 'exe'):
            self.rejected('core/extracted.' + ext, b'local')

    def test_unreviewed_embedded_png(self):
        self.rejected('docs/readme.txt', PNG + b'\0\0\0\0IEND\0\0\0\0')

    def test_package_audit_calls_asset_guard(self):
        with self.assertRaises(ValueError):
            package.audit('test', {'docs/renamed.png': b'local'})

    @unittest.skipUnless(os.environ.get('CEMUVR_TEST_DLL'), 'Set CEMUVR_TEST_DLL for compiled DLL checks')
    def test_compiled_dll_and_resource_tampering(self):
        dll = Path(os.environ['CEMUVR_TEST_DLL']).read_bytes()
        name = 'layer/cemuvr_layer.dll'
        audit_assets({name: dll})
        start = dll.index(PNG)
        changed = bytearray(dll)
        changed[start + 40] ^= 1
        self.rejected(name, bytes(changed))
        self.rejected(name, dll + PNG + b'\0\0\0\0IEND\0\0\0\0')


if __name__ == '__main__':
    unittest.main()
