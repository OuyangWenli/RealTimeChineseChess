#include "G.h"
#include "Board.h"
#include "Piece.h"
#include <string>
#include <algorithm>

General::General(int x, int y, int color) : Piece(x, y, color), isInCheck(false) {
    m_maxActionPoint = 1;
    m_actionPoint = 1;
    setActionPointRecoveryTime(7000); // 将帅的CD为7s
}

void General::setIsInCheck(bool inCheck) {
    isInCheck = inCheck;
}

bool General::canMove(int toX, int toY, const Board &board) const {
    // 统一后的坐标：x 是横向 (0-8), y 是纵向 (0-9)
    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }

    // 特殊逻辑：将帅可以直接见面并吃掉对方
    Piece* opponentGeneral = board.getGeneral(1 - getColor());
    if (opponentGeneral && toX == opponentGeneral->getX() && toY == opponentGeneral->getY()) {
        // 如果目标位置就是对方的将，检查中间是否有阻挡
        if (getX() == toX) { // 必须在同一列
            int y_min = std::min(getY(), toY);
            int y_max = std::max(getY(), toY);
            bool blocked = false;
            for (int y = y_min + 1; y < y_max; y++) {
                if (board.getPiece(toX, y) != nullptr) {
                    blocked = true;
                    break;
                }
            }
            if (!blocked) return true; // 中间没子，可以直接飞过去吃掉
        }
    }

    // 常规逻辑：将帅必须在九宫格内：横向 x=[3,5], 纵向 y=[0,2] 或 [7,9]
    if (toX < 3 || toX > 5) return false;

    if (getColor() == BLACK) { // 黑色方 (上方)
        if (toY < 0 || toY > 2) return false;
    } else { // 红色方 (下方)
        if (toY < 7 || toY > 9) return false;
    }

    int dx = abs(toX - getX());
    int dy = abs(toY - getY());
    return (dx + dy == 1); // 走直线 1 格
}

std::string General::getTypeName() const {
    return (getColor() == RED) ? "Red_G" : "Black_G";
}