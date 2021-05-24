# chia-plot-utils

## script overview

**startnewplot.sh** - Starts a new plot based on settings in $HOME/.plotsettings
**plotomatic-t47.sh** - Continuous automated plotting based on settings in $HOME/.plotsettings. Depends on startnewplot.sh.
**plotstats.sh** - Prints a table of finished and ongoing plots to terminal using  the output from the plot process in combination with tools like "column"

## INSTALL
I will make a script for this eventually. 
```
ln -s $PWD/startnewplot.sh $HOME/.local/bin/newplot
ln -s $PWD/plotomatic-t47.sh $HOME/.local/bin/plotomatic
ln -s $PWD/plotstats.sh $HOME/.local/bin/plotstats

# Make sure to edit .plotsettings to suit your needs
cp $PWD/.plotsettings $HOME

# For the above links to work as intended you need to add ~/.local/bin to your $PATH. This could be done by adding the following line to you shell rc (~/.bashrc, ~/.zshrc etc depending on shell).

export PATH=$PATH:$HOME/.local/bin

```

