require_relative '../test_helper'

describe 'RemoveCommonColorFromPaletteTest' do
  it 'should' do
    delta = 2.5
    # p = Colorcake.compute_palette("../../fixtures/0.jpg", 60)
    # p = Colorcake.color_quantity_in_image(p)
    palette = Marshal.load(File.read('fixtures/0jpg_pallete_marshal'))
    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/0jpg_new_pallete_marshal'))
    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal
  end

  it 'should' do
    delta = 2.5
    palette = Marshal.load(File.read('fixtures/1jpg_pallete_marshal'))

    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/1jpg_new_pallete_marshal'))

    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal

  end

  it 'should' do
    delta = 2.5
    palette = Marshal.load(File.read('fixtures/2jpg_pallete_marshal'))

    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/2jpg_new_pallete_marshal'))

    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal

  end

  it 'should' do
    delta = 2.5
    palette = Marshal.load(File.read('fixtures/3jpg_pallete_marshal'))

    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/3jpg_new_pallete_marshal'))

    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal

  end

  it 'should' do
    delta = 2.5
    palette = Marshal.load(File.read('fixtures/4jpg_pallete_marshal'))

    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/4jpg_new_pallete_marshal'))

    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal

  end

  it 'should' do
    delta = 2.5
    palette = Marshal.load(File.read('fixtures/5jpg_pallete_marshal'))

    new_palette = Colorcake.remove_common_color_from_palette(palette, delta)
    new_palette_marshal = Marshal.load(File.read('fixtures/5jpg_new_pallete_marshal'))

    new_palette.wont_be_nil
    new_palette.must_equal new_palette_marshal
  end

end