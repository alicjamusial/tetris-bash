# Tetris in bash
Really simple tetris game written in Bash. More like a Tetris POC.

Tested on <b>Windows 7</b> with <b>Git Bash command-line console</b>.

### Controls
Use 'a' to move block to left and 'd' to move block to right. Simple!

### Important things & issues
To read keypress in non-blocking way I used <code>stty -icanon</code>. It's really important o turn it off after usage, so it doesn't affect your console. I put <code>stty sane</code> on 'game over' and in Ctrl+C trap. If you exit the script the other way, it's possible that characters in your console will dissapear. Just simply turn the console off and on again :).

### Changable variables
You can change ROWS or COLUMNS to change size of the board. Board and block symbols can also be replaced with something more interesting and nicer - unfortunately my Git Bash doesn't really like unicode, so I had a problem using characters like &#x25A0;. But if you can - do it! :)

### Blocks
As this is my small university project, I didn't really bother with generating complicated blocks - there are 5 types of them, each one coded a bit separately. 
