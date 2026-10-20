export const version = '0.1.0';
// From support/Info.plist: LSMinimumSystemVersion is 14.0. scripts/build.sh builds for the
// host Mac, so releases are Apple Silicon only; switch `chips` once they're universal.
export const macos = 'macOS 14 or later';
export const chips = 'Apple Silicon';
export const origin = 'https://glide.rasmic.xyz';
export const repo = 'https://github.com/michaelshimeles/glide';
export const dmg = `${repo}/releases/latest/download/Glide-universal.dmg`;
