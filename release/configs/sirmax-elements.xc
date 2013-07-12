{
  //"@log": 1,             // ������� @log ������������ ��� ������ �������� � ���, ����� - ������� �����������
  "def": {
    "tf": {                    // ����������� ��� ������� ������
      //"@log": 1,             // ���� ����� �����������
      "size": 30,              // ������ ������
      "font": "$TitleFont",    // ����� ��������         
      "align": "center"        // ������������
    }
  },
  "battleTimer": {             // ����� ������� ������ - ������ _root.battleTimer
    //"_x": "@log",            // ����� ����������� ��������� �������� (_x, � �������, ������ ��� ����� �������)
    "_x": "WIDTH / 2",         // ���������� X �� �������� ������. ����� �������� ��� ����� ����������
    "_y": 50,                  // ���������� Y �� 50 ������
    "dotsMC": {                // TextField: �����
      "_x": "-80/2",           // ����������
      "_y": "-3",              // ����������� ����� ������������ ����
      "_height": 100,          // ������ (� �������)
      "_width": 80,            // ������ (� �������)
      "text": ":",
      "@textFormat": ${"def.tf"}
    },
    "secondsMC": {             // TextField: �������
      "_x": 5,                 // ������������ �����, ������� x = 5
      "_height": 100,          // ������ (� �������)
      "_width": 80,            // ������ (� �������)
      "@textFormat": { "$ref": { "path": "def.tf" }, "align": "left" } // ������ ������ � ������������� �����
    },
    "minutesMC": {             // TextField: ������
      "_x": -85,               // ������������ ������, ������� x = -(width+5)
      "_height": 100,          // ������ (� �������)
      "_width": 80,            // ������ (� �������)
      "@textFormat": { "$ref": { "path": "def.tf" }, "align": "right" } // ������ ������ � ������������� ������
    }
  }
}
