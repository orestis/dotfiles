" don't beep when you run tests - set to 0 to beep
let $SHUTUP = 1

function! FindCurrentTestName()
python << eopython
import vim, re
regex = re.compile('[ ]*def (test\w+)\(')
def isTestName(line):
    return regex.match(line)

testName = ''
row = vim.current.window.cursor[0]-1
while row >= 0:
    line = vim.current.buffer[row]
    if isTestName(line):
        testLine = '"%s"' % line
        testName = regex.match(line).groups(1)[0]
        break
    row-=1
    
vim.command('return %r' % [testName, testLine])
eopython
endfun

function! RunSingleTest(pause)
    let testInfo = FindCurrentTestName()
    let testName = testInfo[0]
    let testLine = testInfo[1]
    if a:pause == 1
        echo "Running " . testName . " of " . bufname("") . " with pause"
        silent execute "!start python " . $VIM_BIN_PATH . '\\test_runner.py -p -f "%" -t ' . testLine
    else
        echo "Running " . testName . " of " . bufname("")
        silent execute "!start python " . $VIM_BIN_PATH . '\\test_runner.py -f "%" -t '. testLine
    endif
endfun

function! RunTest(pause)
    if a:pause == 1
        echo "Running " . bufname("") . " with pause"
        silent execute "!start python " . $VIM_BIN_PATH . '\\test_runner.py -p -f "%"'
    else
        echo "Running " . bufname("")
        silent execute "!start python " . $VIM_BIN_PATH . '\\test_runner.py -f "%"'
    endif
endfun


" Test runners
noremap <f5> :w<cr>:silent call Pyflakes()<cr>:call RunTest(0)<cr><cr>
noremap <s-f5> :w<cr>:silent call Pyflakes()<cr>:call RunTest(1)<cr><cr>
inoremap <f5> <esc>:w<cr>:silent call Pyflakes()<cr>:call RunTest(0)<cr><cr>
inoremap <s-f5> <esc>:w<cr>:silent call Pyflakes()<cr>:call RunTest(1)<cr><cr>
noremap <f6> :w<cr>:silent call Pyflakes()<cr>:call RunSingleTest(0)<cr><cr>
noremap <s-f6> :w<cr>:silent call Pyflakes()<cr>:call RunSingleTest(1)<cr><cr>
inoremap <f6> <esc>:w<cr>:silent call Pyflakes()<cr>:call RunSingleTest(0)<cr><cr>
inoremap <s-f6> <esc>:w<cr>:silent call Pyflakes()<cr>:call RunSingleTest(1)<cr><cr>

" toggles the quickfix window. 
command! -bang -nargs=? QFix call QFixToggle(<bang>0) 
function! QFixToggle(forced) 
  if exists("g:qfix_win") && a:forced == 0 
    cclose 
    normal `T
    delmark T
  else 
    normal mT
    setlocal efm=%A\ \ File\ \"%f\"\\,\ line\ %l\\,\ %m,%C\ %m,%Z
    cgetfile
    copen
  endif 
endfunction 

" used to track the quickfix window 
augroup QFixToggle 
  autocmd! 
  autocmd BufWinEnter quickfix let g:qfix_win = bufnr("$") 
  autocmd BufWinLeave * if exists("g:qfix_win") && expand("<abuf>") == g:qfix_win | unlet! g:qfix_win | endif
augroup END 

"""""" 
map <F4> :call QFixToggle(0)<cr> 
map <C-F4> :call QFixToggle(0)<cr> 

" Switch between test and implementation 
python << EOF
def AlternativeFile():
    import vim
    import os

    path = vim.current.buffer.name
    dirPath, fileName = os.path.split(path)
    baseName, ext = os.path.splitext(fileName)
    _, parentDir = os.path.split(dirPath)
    if parentDir == 'UnitTests':
        name = os.path.join(dirPath, "..", baseName[:-4] + ext)
        name = os.path.normpath(name)
    else:
        name = os.path.join(dirPath, "UnitTests", baseName + 'Test' + ext)

    buffer = PathToBuffer(name)
    if buffer is None:
        vim.command("edit %s" % name)
    else:
        vim.command("b %d" % buffer.number)

def PathToBuffer(path):
    for b in vim.buffers:
        if b.name == path:
            return b
    return None
EOF

map <Leader>a :python AlternativeFile()<cr>

" Rebuild tags
nmap <F12> :silent !start /MIN tags.bat<cr>

" Run Resolver
nmap <C-F5> :silent !start Resolver.bat<cr>

" DONTify commands
command! Dontify %s/def test/def DONTtest/
command! Undontify %s/def DONTtest/def test/
