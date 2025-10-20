#!/usr/bin/env python3
"""
모든 KO 파일에서 example 문장들을 추출하여 텍스트 파일로 저장하는 스크립트
"""

import json
import os
from pathlib import Path

def extract_examples_from_ko_files(data_dir, output_file):
    """
    모든 KO 파일에서 example 문장들을 추출하여 텍스트 파일로 저장
    
    Args:
        data_dir (str): 데이터 파일들이 있는 디렉토리 경로
        output_file (str): 출력할 텍스트 파일 경로
    """
    data_path = Path(data_dir)
    
    # KO 파일들 찾기
    ko_files = sorted(list(data_path.glob("KO_*.json")))
    
    print(f"발견된 KO 파일 수: {len(ko_files)}")
    
    all_examples = []
    
    for ko_file in ko_files:
        print(f"처리 중: {ko_file.name}")
        
        try:
            # KO 파일 읽기
            with open(ko_file, 'r', encoding='utf-8') as f:
                ko_data = json.load(f)
            
            # 파일명에서 카테고리 정보 추출
            filename = ko_file.stem  # 확장자 제거
            category_info = filename.replace("KO_", "")
            
            # 각 항목의 example 추출
            file_examples = []
            for item in ko_data:
                if 'example' in item:
                    example = item['example'].strip()
                    if example:  # 빈 문자열이 아닌 경우만
                        file_examples.append(example)
            
            # 파일별로 섹션 구분하여 추가
            all_examples.append(f"\n{'='*80}")
            all_examples.append(f"파일: {ko_file.name}")
            all_examples.append(f"카테고리: {category_info}")
            all_examples.append(f"예문 수: {len(file_examples)}")
            all_examples.append(f"{'='*80}\n")
            
            # 예문들을 번호와 함께 추가
            for i, example in enumerate(file_examples, 1):
                all_examples.append(f"{i:3d}. {example}")
            
            print(f"  ✅ 완료: {len(file_examples)}개 예문 추출")
            
        except Exception as e:
            print(f"  ❌ 오류 발생: {e}")
            continue
    
    # 전체 통계
    total_examples = sum(1 for line in all_examples if line.strip() and not line.startswith('=') and not line.startswith('파일:') and not line.startswith('카테고리:') and not line.startswith('예문 수:'))
    
    # 헤더 정보 추가
    header = [
        "=" * 80,
        "VOCATCH - 모든 KO 파일의 Example 문장 모음",
        "=" * 80,
        f"총 파일 수: {len(ko_files)}",
        f"총 예문 수: {total_examples}",
        f"생성일: {Path().cwd()}",
        "=" * 80,
        ""
    ]
    
    # 최종 결과를 파일에 저장
    final_content = header + all_examples
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(final_content))
    
    print(f"\n모든 예문이 '{output_file}' 파일에 저장되었습니다!")
    print(f"총 {len(ko_files)}개 파일에서 {total_examples}개의 예문을 추출했습니다.")

def main():
    """메인 함수"""
    # 현재 스크립트의 상위 디렉토리에서 assets/data 경로 찾기
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    data_dir = project_root / "assets" / "data"
    output_file = project_root / "all_ko_examples.txt"
    
    if not data_dir.exists():
        print(f"❌ 데이터 디렉토리를 찾을 수 없습니다: {data_dir}")
        return
    
    print(f"데이터 디렉토리: {data_dir}")
    print(f"출력 파일: {output_file}")
    print("=" * 50)
    
    extract_examples_from_ko_files(data_dir, output_file)

if __name__ == "__main__":
    main()
