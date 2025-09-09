# encoding: utf-8

Jekyll::Hooks.register :site, :post_write do |site|
  css_dir = File.join(site.dest, "assets/css")
  next unless Dir.exist?(css_dir)

  Dir.glob(File.join(css_dir, "**", "*.css")) do |css_path|
    original_css = File.read(css_path, encoding: 'utf-8')
    minified_css = minify_css(original_css)
    File.open(css_path, 'w:UTF-8') { |f| f.write(minified_css) }
    Jekyll.logger.info "CSS Minifier (post_write):", "Minified #{css_path.sub(site.dest + '/', '')}"
  end
end


def minify_css(css)
    css = css.gsub(/\/\*.*?\*\//m, "")          # Remove comments
    css = css.gsub(/\s+/, " ")          # Collapse whitespace to single space
    css = css.gsub(/--[\w-]+:\s*;/, '')     # Strip empty variable declarations (like --color-primary: ;)
    css = css.gsub(/\s*([{}:;,])\s*/, '\1')         # Remove space around symbols
    css = css.gsub(/;}/, "}")           # Remove last semicolon before }
    css = css.gsub(/#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3/, '#\1\2\3')         # Shorten colors like #aabbcc to #abc
    css = css.gsub(/:0(px|em|rem|%)?/, ':0')            # Remove units on zero values
    css = css.gsub(/;\s*;/, ";")            # Remove duplicate semicolons
    css = css.gsub(/\s+!important/, '!important')           # Remove space before !important
    css = css.gsub(/[\r\n]+/, '')       # Remove all remaining newlines and carriage returns
    css.strip           # Strip leading/trailing spaces

    # Note: It's cleaner to chain the .gsub's together, but it won't work with inline comments.
    #       This way, it's easier to label and rearrange rules.
end
