// Jenkinsfile for Secure-Push Security Scanning
// Declarative Pipeline for Jenkins

pipeline {
    agent any

    options {
        // Keep builds for 30 days
        buildDiscarder(logRotator(numToKeepStr: '30'))
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        // Don't allow concurrent builds
        disableConcurrentBuilds()
        // Add timestamps to console output
        timestamps()
    }

    environment {
        // Severity thresholds
        SEVERITY_BLOCK = 'CRITICAL,HIGH'
        SEVERITY_WARN = 'MEDIUM,LOW'

        // Tool versions (update periodically)
        GITLEAKS_VERSION = '8.18.4'
        TRIVY_VERSION = '0.52.0'

        // Report paths
        GITLEAKS_REPORT = 'gitleaks-report.json'
        SEMGREP_REPORT = 'semgrep-report.json'
        TRIVY_REPORT = 'trivy-report.json'
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    echo "🚀 Starting Security Scan Pipeline"
                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "Commit: ${env.GIT_COMMIT}"

                    // Clean workspace
                    cleanWs()

                    // Checkout code
                    checkout scm
                }
            }
        }

        stage('Install Security Tools') {
            steps {
                script {
                    echo "📦 Installing security scanning tools..."

                    // Install Gitleaks
                    sh """
                        if ! command -v gitleaks &> /dev/null; then
                            echo "Installing Gitleaks..."
                            wget -q https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_amd64.tar.gz
                            tar -xzf gitleaks_${GITLEAKS_VERSION}_linux_amd64.tar.gz
                            chmod +x gitleaks
                            sudo mv gitleaks /usr/local/bin/ || mv gitleaks ~/.local/bin/
                        else
                            echo "Gitleaks already installed"
                        fi
                    """

                    // Install Semgrep
                    sh """
                        if ! command -v semgrep &> /dev/null; then
                            echo "Installing Semgrep..."
                            pip3 install --user semgrep
                        else
                            echo "Semgrep already installed"
                        fi
                    """

                    // Install Trivy
                    sh """
                        if ! command -v trivy &> /dev/null; then
                            echo "Installing Trivy..."
                            wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
                            tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
                            chmod +x trivy
                            sudo mv trivy /usr/local/bin/ || mv trivy ~/.local/bin/
                        else
                            echo "Trivy already installed"
                        fi
                    """
                }
            }
        }

        stage('Security Scans') {
            parallel {
                stage('Secret Detection') {
                    steps {
                        script {
                            echo "🔍 Running Gitleaks secret detection..."

                            def configArg = ""
                            if (fileExists('.claude/skills/secure-push/configs/gitleaks.toml')) {
                                configArg = "--config=.claude/skills/secure-push/configs/gitleaks.toml"
                            }

                            def exitCode = sh(
                                script: """
                                    gitleaks detect \
                                        ${configArg} \
                                        --report-path=${GITLEAKS_REPORT} \
                                        --report-format=json \
                                        --no-banner \
                                        --redact || true
                                """,
                                returnStatus: true
                            )

                            if (fileExists(GITLEAKS_REPORT)) {
                                def report = readJSON file: GITLEAKS_REPORT
                                def secretCount = report.size()

                                if (secretCount > 0) {
                                    error("❌ Found ${secretCount} secret(s) in code!")
                                } else {
                                    echo "✅ No secrets detected"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            // Archive report
                            archiveArtifacts artifacts: "${GITLEAKS_REPORT}", allowEmptyArchive: true
                        }
                    }
                }

                stage('Code Analysis') {
                    steps {
                        script {
                            echo "🔎 Running Semgrep code analysis..."

                            sh """
                                semgrep scan \
                                    --config=p/security-audit \
                                    --config=p/owasp-top-ten \
                                    --config=p/cwe-top-25 \
                                    --config=.claude/skills/secure-push/configs/semgrep.yaml \
                                    --config=.claude/skills/secure-push/configs/languages/ \
                                    --json \
                                    --output=${SEMGREP_REPORT} \
                                    --metrics=off \
                                    --quiet \
                                    . || true
                            """

                            if (fileExists(SEMGREP_REPORT)) {
                                def report = readJSON file: SEMGREP_REPORT
                                def errors = report.results.findAll { it.extra.severity == 'ERROR' }
                                def warnings = report.results.findAll { it.extra.severity == 'WARNING' }

                                echo "Found ${errors.size()} error(s) and ${warnings.size()} warning(s)"

                                if (errors.size() > 0) {
                                    // Print first 5 errors
                                    errors.take(5).each { err ->
                                        echo "❌ [${err.extra.severity}] ${err.extra.message}"
                                        echo "   → ${err.path}:${err.start.line}"
                                    }
                                    error("❌ Found ${errors.size()} critical code issue(s)!")
                                } else {
                                    echo "✅ No critical code issues found"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            // Archive report
                            archiveArtifacts artifacts: "${SEMGREP_REPORT}", allowEmptyArchive: true

                            // Publish to warnings-ng plugin if available
                            recordIssues(
                                enabledForFailure: true,
                                tools: [semgrep(pattern: SEMGREP_REPORT)]
                            )
                        }
                    }
                }

                stage('Dependency Scan') {
                    steps {
                        script {
                            echo "🔬 Running Trivy dependency scan..."

                            sh """
                                trivy fs \
                                    --severity ${SEVERITY_BLOCK},${SEVERITY_WARN} \
                                    --format json \
                                    --output ${TRIVY_REPORT} \
                                    --timeout 10m \
                                    .
                            """

                            if (fileExists(TRIVY_REPORT)) {
                                def report = readJSON file: TRIVY_REPORT

                                def critical = 0
                                def high = 0
                                def medium = 0
                                def low = 0

                                report.Results.each { result ->
                                    result.Vulnerabilities?.each { vuln ->
                                        switch(vuln.Severity) {
                                            case 'CRITICAL': critical++; break
                                            case 'HIGH': high++; break
                                            case 'MEDIUM': medium++; break
                                            case 'LOW': low++; break
                                        }
                                    }
                                }

                                echo "Vulnerability Summary:"
                                echo "  Critical: ${critical}"
                                echo "  High: ${high}"
                                echo "  Medium: ${medium}"
                                echo "  Low: ${low}"

                                if (critical > 0 || high > 0) {
                                    error("❌ Found ${critical} critical and ${high} high severity vulnerabilities!")
                                } else {
                                    echo "✅ No critical or high vulnerabilities found"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            // Archive report
                            archiveArtifacts artifacts: "${TRIVY_REPORT}", allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        stage('Security Report') {
            steps {
                script {
                    echo "📊 Generating security summary..."

                    def summary = """
                    # 🔒 Security Scan Summary

                    **Build:** ${env.BUILD_NUMBER}
                    **Branch:** ${env.BRANCH_NAME}
                    **Commit:** ${env.GIT_COMMIT}
                    **Date:** ${new Date()}

                    ## Results

                    """

                    // Secret Scan Summary
                    if (fileExists(GITLEAKS_REPORT)) {
                        def report = readJSON file: GITLEAKS_REPORT
                        def count = report.size()
                        if (count == 0) {
                            summary += "✅ **Secret Scanning:** No secrets detected\n"
                        } else {
                            summary += "❌ **Secret Scanning:** ${count} secret(s) found\n"
                        }
                    }

                    // Code Scan Summary
                    if (fileExists(SEMGREP_REPORT)) {
                        def report = readJSON file: SEMGREP_REPORT
                        def errors = report.results.findAll { it.extra.severity == 'ERROR' }.size()
                        def warnings = report.results.findAll { it.extra.severity == 'WARNING' }.size()
                        if (errors == 0) {
                            summary += "✅ **Code Analysis:** No critical issues (Warnings: ${warnings})\n"
                        } else {
                            summary += "❌ **Code Analysis:** ${errors} critical issue(s) found\n"
                        }
                    }

                    // Dependency Scan Summary
                    if (fileExists(TRIVY_REPORT)) {
                        def report = readJSON file: TRIVY_REPORT
                        def critical = 0, high = 0, medium = 0, low = 0

                        report.Results.each { result ->
                            result.Vulnerabilities?.each { vuln ->
                                switch(vuln.Severity) {
                                    case 'CRITICAL': critical++; break
                                    case 'HIGH': high++; break
                                    case 'MEDIUM': medium++; break
                                    case 'LOW': low++; break
                                }
                            }
                        }

                        summary += "\n**Dependency Vulnerabilities:**\n"
                        summary += "- Critical: ${critical}\n"
                        summary += "- High: ${high}\n"
                        summary += "- Medium: ${medium}\n"
                        summary += "- Low: ${low}\n"
                    }

                    writeFile file: 'security-summary.md', text: summary
                    echo summary

                    // Archive summary
                    archiveArtifacts artifacts: 'security-summary.md'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Security scan completed successfully!"
        }
        failure {
            echo "❌ Security scan failed - review findings above"

            // Send notification (configure email/Slack/etc.)
            // emailext (
            //     subject: "Security Scan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //     body: "Security vulnerabilities detected. Check ${env.BUILD_URL} for details.",
            //     to: "security@example.com"
            // )
        }
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
