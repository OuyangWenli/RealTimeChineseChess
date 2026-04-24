#include "H.h"
#include "Board.h"
#include "Piece.h"
#include <string>

Horse::Horse(int x, int y, int color) : Piece(x, y, color) {
    m_maxActionPoint = 1;
    m_actionPoint = 1;
    setActionPointRecoveryTime(5000); // 马的CD
}
bool Horse::canMove(int toX, int toY, const Board &board) const {
    Piece* target = board.getPiece(toX, toY);
    if (target != nullptr && target->getColor() == getColor()) {
        return false; // 不能吃自己的棋子
    }

    int dx = toX - getX();
    int dy = toY - getY();
    int adx = abs(dx);
    int ady = abs(dy);

    if ((adx == 2 && ady == 1) || (adx == 1 && ady == 2)) { // 马走日
        int legX, legY;
        if (adx == 2) {
            // 横向走2步，马腿在横向1步的位置
            legX = getX() + (dx / 2);
            legY = getY();
        } else {
            // 纵向走2步，马腿在纵向1步的位置
            legX = getX();
            legY = getY() + (dy / 2);
        }

        if (board.getPiece(legX, legY) != nullptr && board.getPiece(legX, legY)->isAlive()) {
            return false; // 马腿被堵住了
        }
        return true;
    }
    return false;
}

std::string Horse::getTypeName() const {
    return (getColor() == RED) ? "Red_H" : "Black_H";
}