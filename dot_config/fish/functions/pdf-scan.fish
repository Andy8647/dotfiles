function pdf-scan --description "Scan PDF files for hidden prompt injection attacks"
    /Users/andy/Projects/pdf-injection-scanner/.venv/bin/python -m pdf_injection_scanner.scanner $argv
end
