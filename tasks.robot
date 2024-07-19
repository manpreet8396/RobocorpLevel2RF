*** Settings ***
Documentation       Robot to get Certification Level 2.

Library    RPA.Browser.Selenium    auto_close=False
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive

*** Variables ***
${UrlPagina}    https://robotsparebinindustries.com/#/robot-order
${UrlFile}    https://robotsparebinindustries.com/orders.csv
${OrdersFileCSV}    orders.csv
${PDFFileRoot}    ${OUTPUT_DIR}${/}TransactionData${/}RobotTransaction
${PDFSSRoot}    ${OUTPUT_DIR}${/}TransactionData${/}RobotImage

*** Tasks ***
Process Robot Data
    Open transaction page
    Close PoPuP
    Download CSV Data
    Read Excel Data
    Generate zip Files
    [Teardown]    Close transaction page

*** Keywords ***
Open transaction page
    Open Available Browser    ${UrlPagina}
    Maximize Browser Window
Close PoPuP
    Wait Until Page Contains Element    class:modal-content
    Click Button    OK
Download CSV Data
    Download    ${UrlFile}    overwrite=True
    Sleep    5
Read Excel Data
    ${Data}=    Read table from CSV    ${OrdersFileCSV}
    FOR    ${Transaction}    IN    @{Data}
        Fill transaction Data   ${Transaction} 
    END
Fill transaction Data
    [Arguments]    ${Transaction}
    Select From List By Value    head    ${Transaction}[Head]
    Select Radio Button    body    ${Transaction}[Body]
    ${IDLegs}=    Get Element Attribute    css:input[placeholder="Enter the part number for the legs"]    id
    Input Text    ${IDLegs}    ${Transaction}[Legs]
    Input Text    address    ${Transaction}[Address]
    Sleep    2
    Click Button    order
    Sleep    1
    TRY
        Take transaction evidence    ${Transaction}
        Click Button    order-another  
    EXCEPT
        Click Button    id:order
        Sleep    1
        Take transaction evidence    ${Transaction}
        Click Button    order-another   
        Sleep    1
    END
    Close PoPuP
Take transaction evidence
    [Arguments]    ${Transaction}
    TRY
    Wait Until Page Contains Element    id:receipt
    EXCEPT
        Click Button    id:order
        Sleep    2
    END
    ${HTMLData}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${HTMLData}    ${PDFFileRoot}_${Transaction}[Order number].pdf
    Screenshot    id:robot-preview    ${PDFSSRoot}_${Transaction}[Order number].png  
    ${FileList}=    Create List
    ...    ${PDFFileRoot}_${Transaction}[Order number].pdf
    ...    ${PDFSSRoot}_${Transaction}[Order number].png:align=center
    Add Files To Pdf    ${FileList}    ${PDFFileRoot}_${Transaction}[Order number].pdf
Generate zip Files
    Archive Folder With Zip    ${OUTPUT_DIR}${/}TransactionData    ${OUTPUT_DIR}${/}TransactionData.zip
Close transaction page
    Close Browser

