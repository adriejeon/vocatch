#!/usr/bin/env python3
"""
EN 파일의 내용을 KO 파일로 교체하는 스크립트

변환 규칙:
1. EN 파일의 word 필드를 KO 파일의 meaning_ko 값으로 교체
2. KO 파일의 meaning_ko 필드명을 meaning_en으로 변경
3. meaning_en 필드의 값은 EN 파일의 word 값으로 설정
"""

import json
import os
import shutil
from pathlib import Path

def swap_en_ko_files(data_dir):
    """
    EN 파일과 KO 파일을 교체하는 함수
    
    Args:
        data_dir (str): 데이터 파일들이 있는 디렉토리 경로
    """
    data_path = Path(data_dir)
    
    # EN 파일들 찾기
    en_files = list(data_path.glob("EN_*.json"))
    
    print(f"발견된 EN 파일 수: {len(en_files)}")
    
    for en_file in en_files:
        # 해당하는 KO 파일 찾기
        ko_filename = en_file.name.replace("EN_", "KO_")
        ko_file = data_path / ko_filename
        
        if not ko_file.exists():
            print(f"⚠️  해당하는 KO 파일을 찾을 수 없습니다: {ko_filename}")
            continue
            
        print(f"처리 중: {en_file.name} -> {ko_filename}")
        
        try:
            # EN 파일 읽기
            with open(en_file, 'r', encoding='utf-8') as f:
                en_data = json.load(f)
            
            # KO 파일 읽기
            with open(ko_file, 'r', encoding='utf-8') as f:
                ko_data = json.load(f)
            
            # EN 파일의 내용을 KO 파일로 변환
            converted_data = []
            
            for en_item in en_data:
                # EN 파일의 word를 meaning_ko로, meaning_ko를 meaning_en으로 변환
                converted_item = {
                    "word": en_item["meaning_ko"],  # EN의 meaning_ko를 word로
                    "meaning_en": en_item["word"],  # EN의 word를 meaning_en으로
                    "pos": en_item["pos"],
                    "example": en_item["example"],
                    "level": en_item["level"],
                    "category": en_item["category"]
                }
                converted_data.append(converted_item)
            
            # 백업 생성
            backup_file = ko_file.with_suffix('.json.backup')
            shutil.copy2(ko_file, backup_file)
            print(f"  백업 생성: {backup_file.name}")
            
            # 변환된 데이터를 KO 파일에 저장
            with open(ko_file, 'w', encoding='utf-8') as f:
                json.dump(converted_data, f, ensure_ascii=False, indent=2)
            
            print(f"  ✅ 완료: {ko_filename}")
            
        except Exception as e:
            print(f"  ❌ 오류 발생: {e}")
            continue
    
    print("\n모든 파일 처리가 완료되었습니다!")

def main():
    """메인 함수"""
    # 현재 스크립트의 상위 디렉토리에서 assets/data 경로 찾기
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    data_dir = project_root / "assets" / "data"
    
    if not data_dir.exists():
        print(f"❌ 데이터 디렉토리를 찾을 수 없습니다: {data_dir}")
        return
    
    print(f"데이터 디렉토리: {data_dir}")
    print("=" * 50)
    
    # 자동 실행 (사용자 확인 없이)
    print("EN 파일을 KO 파일로 교체합니다...")
    swap_en_ko_files(data_dir)

if __name__ == "__main__":
    main()
