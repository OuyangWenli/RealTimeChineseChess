#pragma once
#include "Piece.h"
#include <string>

class Board;

class Cannon : public Piece
{
public:
    Cannon(int x, int y, int color);
    bool canMove(int toX, int toY, const Board &board) const override;
    std::string getTypeName() const override;
};
