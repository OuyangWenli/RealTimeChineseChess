#include "S.h"
#include "Board.h"
#include "Piece.h"
#include <string>

Soldier::Soldier(int x, int y, int color) : Piece(x, y, color) {
    setActionPointRecoveryTime(5000); // 兵的CD为5s
}

bool Soldier::canMove(int toX, int toY, const Board &board) const {
    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }

    // 统一后的坐标：x 是横向 (0-8), y 是纵向 (0-9)
    if (getColor() == BLACK) { // 黑色卒 (从上往下 y 增加)
        if (getY() <= 4) { // 未过河 (黑方河界 y=4)
            return (toY == getY() + 1 && toX == getX());
        } else { // 已过河
            if (toY < getY()) return false; // 不能后退
            return (abs(toX - getX()) + abs(toY - getY()) == 1);
        }
    } else { // 红色兵 (从下往上 y 减小)
        if (getY() >= 5) { // 未过河 (红方河界 y=5)
            return (toY == getY() - 1 && toX == getX());
        } else { // 已过河
            if (toY > getY()) return false; // 不能后退
            return (abs(toX - getX()) + abs(toY - getY()) == 1);
        }
    }
}

std::string Soldier::getTypeName() const {
    return (getColor() == RED) ? "Red_S" : "Black_S";
}
