#include "C.h"
#include "Board.h"
#include "Piece.h"
#include <string>

Cannon::Cannon(int x, int y, int color) : Piece(x, y, color) {
    m_maxActionPoint = 1;
    m_actionPoint = 1;
    setActionPointRecoveryTime(5800); // 炮的CD
}

bool Cannon::canMove(int toX, int toY, const Board &board) const {
    if (toX != getX() && toY != getY()) {
        return false; // 炮只能横竖移动
    }
    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }
    
    int count = 0;
    if (toX == getX()) { // 横向移动
        int step = (toY > getY()) ? 1 : -1;
        for (int y = getY() + step; y != toY; y += step) {
            if (board.getPiece(getX(), y) != nullptr) {
                count++;
            }
        }
    } else { // 竖向移动
        int step = (toX > getX()) ? 1 : -1;
        for (int x = getX() + step; x != toX; x += step) {
            if (board.getPiece(x, getY()) != nullptr) {
                count++;
            }
        }
    }

    if (target == nullptr) { 
        return count == 0;
    } else { 
        return count == 1;
    }
}

std::string Cannon::getTypeName() const {
    return (getColor() == RED) ? "Red_C" : "Black_C";
}
