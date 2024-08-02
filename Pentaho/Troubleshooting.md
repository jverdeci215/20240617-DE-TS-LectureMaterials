# Troubleshooting

## If Spoon.bat will not launch
1. Make sure that you have 64-bit Java installed.
    - In order to check head to your `PC` -> `Program Files` -> `Java`
        - If the folder does not exist then Java is not installed
        - **IMPORTANT: it must be in the `Program Files` folder not `Program Files x86` Folder**
2. If you do not head to [Java Download](https://www.java.com/en/download/manual.jsp) and use the Offline download of 64-bit.
3. Verify that Java is installed in the `Program Files` folder.
4. Set up Pentaho Environment variables
    - In file explorer right click `PC` and select `Properties`
    - Select `Advanced System Settings`
    - Select `Environment Variables...`
    - Under `User Variables for <user name>` select the `New...` option.
        - Variable Name: `PENTAHO_JAVA_HOME`
        - Variable Value: `C:\Program Files\Java\jre1.8.0_421` or replace with the file path to your JRE
5. Attempt to launch Spoon Again.
6. If Spoon still does not launch.
    - Head back yo your Environment Variables
    - Set up a new environment variable
        - Variable Name: `PENTAHO_DI_JAVA_OPTIONS`
        - Variable Value: `-Xms1024m`
7. Spoon should launch successfully. If not attempt to run Spoon.bat as an administrator.