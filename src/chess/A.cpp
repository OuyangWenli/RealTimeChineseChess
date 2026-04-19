#include "A.h"
#include "Piece.h"
#include "Board.h"
#include <string>

Advisor::Advisor(int x, int y, int color) : Piece(x, y, color) {
    setActionPointRecoveryTime(4700); // 士的CD为4.7s
}

bool Advisor::canMove(int toX, int toY, const Board &board) const {
    // 统一后的坐标：x 是横向 (0-8), y 是纵向 (0-9)
    // 士必须在九宫格内：x=[3,5], y=[0,2] 或 [7,9]
    if (toX < 3 || toX > 5) {
        return false;
    }
    if (getColor() == BLACK) { // 黑色方 (上方)
        if (toY < 0 || toY > 2) {
            return false;
        }
    } else { // 红色方 (下方)
        if (toY < 7 || toY > 9) {
            return false;
        }
    }

    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }

    int dx = abs(toX - getX());
    int dy = abs(toY - getY());
    return (dx == 1 && dy == 1); // 士走对角线 1 格
}

std::string Advisor::getTypeName() const {
    return (getColor() == RED) ? "Red_A" : "Black_A";
}
