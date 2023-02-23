*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.Robocorp.WorkItems
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.FileSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Click the annoying button
    Download csv file
    Fill the form using data from CSV
    Zip them up


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Click the annoying button
    Click Button    I guess so...

Download csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Fill the form for one robot
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Take a screenshot of the robot    ${order}
    Submit the order
    Order another robot    ${order}

Fill the form using data from CSV
    ${orders}=    Read table from CSV    orders.csv    header = ${True}
    Close Workbook
    FOR    ${order}    IN    @{orders}
        Wait Until Keyword Succeeds    10x    0.2 sec    Fill the form for one robot    ${order}
        Embed screenshot into PDF    ${order}
    END

Submit the order
    Click Button    Order

Order another robot
    [Arguments]    ${order}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts/receipt${order}[Order number].pdf
    Click Button    Order another robot
    Click the annoying button

Take a screenshot of the robot
    [Arguments]    ${order}
    Click Button    Preview
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots/preview${order}[Order number].png

Embed screenshot into PDF
    [Arguments]    ${order}
    Open Pdf    ${OUTPUT_DIR}${/}receipts/receipt${order}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}screenshots/preview${order}[Order number].png
    ...    ${OUTPUT_DIR}${/}receipts/receipt${order}[Order number].pdf
    Close PDF

Zip them up
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip
