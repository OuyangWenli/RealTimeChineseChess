#pragma once
#include "Piece.h"
#include <string>

class Board;

class General : public Piece
{
private:
    bool isInCheck; // 是否处于将军状态
public:
    General(int x, int y, int color);
    bool canMove(int toX, int toY, const Board &board) const override;
    std::string getTypeName() const override;
    void setIsInCheck(bool inCheck);
};
