#include "E.h"
#include "Board.h"
#include "Piece.h"
#include <string>

Elephant::Elephant(int x, int y, int color) : Piece(x, y, color) {
    setActionPointRecoveryTime(5400); // 象的CD为5.4s
}

bool Elephant::canMove(int toX, int toY, const Board &board) const {
    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }

    // 象不能过河 (各在 5 行范围内)
    if (getColor() == BLACK) { // 黑色方 (上方 y=0-4)
        if (toY > 4) return false;
    } else { // 红色方 (下方 y=5-9)
        if (toY < 5) return false;
    }

    int dx = abs(toX - getX());
    int dy = abs(toY - getY());
    if (dx == 2 && dy == 2) { // 象走田
        int eyeX = (toX + getX()) / 2;
        int eyeY = (toY + getY()) / 2;
        if (board.getPiece(eyeX, eyeY) != nullptr) {
            return false; // 象眼被堵住了
        }
        return true;
    }
    return false;
}

std::string Elephant::getTypeName() const {
    return (getColor() == RED) ? "Red_E" : "Black_E";
}
