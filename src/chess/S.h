#pragma once
#include "Piece.h"
#include <string>

class Board;

class Soldier : public Piece
{
public:
    Soldier(int x, int y, int color);
    bool canMove(int toX, int toY, const Board &board) const override;
    std::string getTypeName() const override;
};