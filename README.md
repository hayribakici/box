# box

Create a box around some text.

## Usage

```markdown
:::{.box}

Your text here

:::
```

### Options

You can add titles and define fill and border colors with

```markdown
:::{.box fillcolor="#ababab" bordercolor="#ffffff"}
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

