# box

Pandoc lua-filter that creates a box around some text.

## Run 

Run this filter e.g. with `pandoc sample.md --lua-filter=box.lua --output=sample.pdf`.

## Usage

The simplest usage would be to wrap three colons `:::` with the `{.box}` attribute around some text. `box` creates a box around it with the default border and fill color of `tcolorbox` (see [sample.pdf](https://github.com/hayribakici/box/blob/main/sample.pdf)).

```markdown
:::{.box}

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet
clita kasd gubergren.

:::
```

Resulting in

<img src="https://github.com/hayribakici/box/assets/3295340/71f1b8c1-dbfb-4e21-aeae-5a54468910ce" width="300px" />

### Options

You can add titles and define fill and border colors with

```markdown
:::{.box fillcolor="#ababab" bordercolor="#000000"}
> Your title as a blockquote followed by an empty line

Your regular markdown content here such as

Here is some **Text** that you can *display* inside a Box!
You can also add your favorite markdown commands such as

> a nice blockquote

Maybe a table?!

| Here | Here|
|------|----:|
|Here  | and here |

And some bullet points

- Some
- important
- bullet
- points

and enumerations

1. first
2. second
3. third

:::
```



This pandoc filter is basically wrapping a `tcolorbox` around the text in markdown and provides the options:

- **fillcolor**: the background color of the box. Only supports html colors.
- **bordercolor**: the framecolor of the box. Only supports html colors.
- The title is set by the first paragraph.

## Caveats

1. So far the display of images are not supported. Latex throws an error message

  ```terminal
  ! LaTeX Error: Not in outer par mode.

  See the LaTeX manual or LaTeX Companion for explanation.
  Type  H <return>  for immediate help.
   ...                                              
                                                  
  l.108 \centering
  ```

  Any help here is appreciated.

2. The `tcolorbox` package provides much more options than this filter. If you think that this filter should have more options, you can create a issue for that.

