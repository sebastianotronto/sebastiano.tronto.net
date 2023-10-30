# Spooky shell expansions

*Let me tell you a story to chill the bones*  
*One that happened to me long time ago*

*It was a dark and cold night*  
*Plague spreading outside*  

*In the summer of '20*  
*I was hacking alone*  
*A little program I wanted to install*  
*Not in `/usr/local`, but in my `$HOME`*

*Young and foolish I was*  
*As I changed the Makefile*  
*`PREFIX = ~/.local`*  
*And then `make` I typed*

*That did not work, of course*  
*And I soon realized*  
*A new folder named `~`*  
*Had shown up in my `$HOME`*

*"How foolish I was" - I thought*  
*"That must not work,*  
*A Makefile won't expand*  
*As a shell script sure does"*

*A folder named `~`*  
*When left alone,*  
*Is no reason to fear*  
*Does no harm at all*  

*But care must be taken*  
*And alas, I did not*  
*Soon to learn the hard way*  
*What a `~` gives, a `~` takes away*

*"Let this be undone!" I exclaimed*

*As I typed*

*Four little bytes*  

```
$ rm ~
```
