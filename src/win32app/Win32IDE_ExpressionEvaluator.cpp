// ============================================================================
// Win32IDE_ExpressionEvaluator.cpp — Watch Expression & Hover Evaluation
// ============================================================================
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: loadVariablesForFrame invent synthetic x/y/name + evaluate invent dummy true (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include "Win32IDE.h"
#include <sstream>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ExpressionEvaluator] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

class Win32IDE::ExpressionEvaluator
{
  public:
    ExpressionEvaluator(Win32IDE* ide) : m_ide(ide)
    {
        (void)m_ide;
    }

    bool evaluate(const std::string& expression, int frameId, std::string& result, std::string& type)
    {
        (void)expression;
        (void)frameId;
        result.clear();
        type.clear();
        // Was: invent synthetic frame vars + dummy sizeof/strlen/member values → true.
        GateFiction("ExpressionEvaluator::evaluate");
        m_error = "FEATURE_FICTION=1 FAIL_CLOSED ExpressionEvaluator (no live debugger bind)";
        return false;
    }

    const std::string& getError() const
    {
        return m_error;
    }

  private:
    Win32IDE* m_ide;
    std::string m_error;
};

bool Win32IDE::evaluateWatchExpression(const std::string& expression, int frameId, std::string& result,
                                        std::string& type)
{
    // Real local-variable map only — never invent synthetic debugger values.
    if (!m_localVariables.empty() && !expression.empty() && expression.front() == '$')
    {
        std::string varName = expression.substr(1);
        for (const auto& var : m_localVariables)
        {
            if (var.name == varName)
            {
                result = var.value;
                type = var.type;
                return true;
            }
        }
    }

    ExpressionEvaluator evaluator(this);
    return evaluator.evaluate(expression, frameId, result, type);
}

std::string Win32IDE::getHoverValueAtPosition(int line, int column, int frameId)
{
    if (line < 1 || column < 1 || frameId < 0) return "";

    std::string docText = getEditorText();
    if (docText.empty()) return "";

    std::string lineText;
    {
        std::istringstream iss(docText);
        int currentLine = 1;
        while (std::getline(iss, lineText) && currentLine < line) {
            ++currentLine;
        }
        if (currentLine != line) return "";
    }
    if (lineText.empty()) return "";

    int col = column - 1;
    if (col >= static_cast<int>(lineText.size())) return "";

    int start = col;
    while (start > 0 && (std::isalnum(static_cast<unsigned char>(lineText[start - 1])) || lineText[start - 1] == '_')) {
        --start;
    }
    int end = col;
    while (end < static_cast<int>(lineText.size()) && (std::isalnum(static_cast<unsigned char>(lineText[end])) || lineText[end] == '_')) {
        ++end;
    }

    if (start >= end) return "";
    std::string identifier = lineText.substr(start, end - start);

    std::string result;
    std::string type;
    if (evaluateWatchExpression(identifier, frameId, result, type)) {
        return type + " " + identifier + " = " + result;
    }

    return "";
}
