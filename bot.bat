@echo off

set "brainFile=brain.txt"
set "dictionaryFile=dictionary.txt"
set "generateAsciiScript=generateascii.ps1"

echo Welcome to StAPI, the Smart Chatbot!

rem Download dictionary if it doesn't exist
if not exist "%dictionaryFile%" (
    echo Downloading dictionary... Please wait.
    powershell.exe -Command "(New-Object System.Net.WebClient).DownloadFile('https://list-english.ru/img/newpdf/dictpdf/6.pdf', '%dictionaryFile%')"
)

rem Save the generateascii.ps1 script if it doesn't exist
if not exist "%generateAsciiScript%" (
    echo Creating generateascii.ps1 script... Please wait.
    echo. > "%generateAsciiScript%"
    echo 'param($textInput)' >> "%generateAsciiScript%"
    echo 'if (!(Get-Module -ListAvailable -Name Figlet)) {' >> "%generateAsciiScript%"
    echo '    Install-Module -Name Figlet -Force' >> "%generateAsciiScript%"
    echo '}' >> "%generateAsciiScript%"
    echo '$asciiArt = New-Object Figlet.FigletFont' >> "%generateAsciiScript%"
    echo '$figlet = New-Object Figlet.Figlet($asciiArt)' >> "%generateAsciiScript%"
    echo '$asciiArtResult = $figlet.ToAsciiArt($textInput)' >> "%generateAsciiScript%"
    echo 'Write-Output $asciiArtResult' >> "%generateAsciiScript%"
)

:chat
echo.
set /p "input=You: "
echo.

rem Save user input to brain.txt
echo User: %input% >> "%brainFile%"

rem Check if input is a question
echo %input% | findstr /C:"?" >nul
if %errorlevel% equ 0 (
    rem Fetch information using PowerShell and save to brain.txt
    echo StAPI is searching for an answer... Please wait.
    powershell.exe -Command "(Invoke-WebRequest -Uri 'https://www.example.com/search?q=%input%' -UseBasicParsing).Content" >> "%brainFile%"
) else (
    rem Retrieve last response from brain.txt
    for /f "usebackq delims=" %%i in ("%brainFile%") do set "response=%%i"
    echo StAPI: %response%
    
    rem Check if the response is related to code writing
    echo %response% | findstr /C:"StAPI can help you write code." >nul
    if %errorlevel% equ 0 (
        rem Prompt user to provide code
        echo.
        echo StAPI: What code would you like StAPI to write for you?
        set /p "codeInput=You: "
        echo StAPI is writing the code... Please wait.
        echo Code: %codeInput% >> "%brainFile%"
        rem Execute the code using PowerShell
        powershell.exe -Command "%codeInput%"
        echo StAPI has executed the code successfully.
    ) else (
        rem Check if the user wants to generate ASCII art
        echo %input% | findstr /C:"Generate ascii art" >nul
        if %errorlevel% equ 0 (
            rem Prompt user for text input for ASCII art generation
            echo.
            echo StAPI: Please enter the text for ASCII art generation:
            set /p "asciiInput=You: "
            echo StAPI is generating ASCII art... Please wait.
            rem Execute the generateascii.ps1 script using PowerShell
            powershell.exe -ExecutionPolicy Bypass -File "%generateAsciiScript%" "%asciiInput%"
        ) else (
            goto chat
        )
    )
)

rem Retrieve last response from brain.txt
for /f "usebackq delims=" %%i in ("%brainFile%") do set "response=%%i"

rem Check if the response contains an answer
findstr /C:"<answer>" "%brainFile%" >nul
if %errorlevel% equ 0 (
    rem Extract the answer from the response
    for /f "delims=<>" %%j in ("%response%") do set "answer=%%j"
    
    echo StAPI: %answer%
) else (
    echo StAPI doesn't have an answer. Let me search online...

    rem Scrape the web for the answer using PowerShell and save to brain.txt
    echo StAPI is searching for an answer... Please wait.
    powershell.exe -Command "(Invoke-WebRequest -Uri 'https://www.example.com/search?q=%input%' -UseBasicParsing).Content" >> "%brainFile%"

    rem Retrieve last response from brain.txt
    for /f "usebackq delims=" %%i in ("%brainFile%") do set "response=%%i"

    rem Extract the answer from the response
    for /f "delims=<>" %%j in ("%response%") do set "answer=%%j"

    echo StAPI: %answer%
)

rem Store information in dictionary.txt
echo %input%=%answer%>> "%dictionaryFile%"

goto chat
