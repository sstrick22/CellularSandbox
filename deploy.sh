# This should only be used on the gh-pages branch to
# build the web page and copy it to the root directory.
pub get
pub build
rm -rf packages/
cp build/web/* ./ -R