#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
KO 파일들의 example 필드를 translate_examples.csv의 한국어 예문으로 업데이트하는 스크립트
"""

import json
import re
from pathlib import Path

def read_translated_examples(csv_file):
    """
    translate_examples.csv 파일에서 번역된 한국어 예문들을 읽어서 리스트로 반환
    """
    with open(csv_file, 'r', encoding='utf-8') as f:
        content = f.read().strip()
    
    # 번호와 함께 있는 예문들을 파싱
    # 예: "1. 오늘 나온 최신 뉴스 봤어요? 2. 그들은 지역 정치에 대해 보도합니다."
    examples = []
    
    # 번호 패턴으로 분리
    pattern = r'(\d+)\.\s*([^0-9]+?)(?=\s*\d+\.|$)'
    matches = re.findall(pattern, content)
    
    for match in matches:
        example_text = match[1].strip()
        if example_text:
            examples.append(example_text)
    
    print(f"총 {len(examples)}개의 번역된 예문을 읽었습니다.")
    return examples

def read_all_ko_examples_order(txt_file):
    """
    all_ko_examples.txt 파일에서 예문 순서를 파악
    """
    with open(txt_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 파일별 예문 수를 추출 (더 정확한 패턴 사용)
    file_sections = re.findall(r'파일: (KO_.*?\.json)\n카테고리: .*?\n예문 수: (\d+)', content)
    
    file_order = []
    for filename, count in file_sections:
        file_order.append((filename, int(count)))
    
    print(f"파일 순서: {[f[0] for f in file_order]}")
    print(f"각 파일의 예문 수: {[f[1] for f in file_order]}")
    return file_order

def update_ko_files(data_dir, translated_examples, file_order):
    """
    KO 파일들의 example 필드를 새로운 한국어 예문으로 업데이트
    """
    example_index = 0
    
    for filename, example_count in file_order:
        file_path = data_dir / filename
        
        if not file_path.exists():
            print(f"❌ 파일을 찾을 수 없습니다: {filename}")
            continue
        
        print(f"\n📝 {filename} 처리 중... (예문 수: {example_count})")
        
        # JSON 파일 읽기
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 각 항목의 example 필드 업데이트
        updated_count = 0
        for item in data:
            if example_index < len(translated_examples):
                item['example'] = translated_examples[example_index]
                example_index += 1
                updated_count += 1
            else:
                print(f"⚠️  번역된 예문이 부족합니다. {filename}의 일부 예문이 업데이트되지 않았습니다.")
                break
        
        # 파일 저장
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {filename}: {updated_count}개 예문 업데이트 완료")
    
    print(f"\n🎉 모든 KO 파일 업데이트 완료!")
    print(f"총 {example_index}개의 예문이 업데이트되었습니다.")

def main():
    """메인 함수"""
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    data_dir = project_root / "assets" / "data"
    
    # 파일 경로 설정
    csv_file = project_root / "translate_examples.csv"
    txt_file = project_root / "all_ko_examples.txt"
    
    print("=" * 60)
    print("KO 파일들의 example 필드를 번역된 한국어 예문으로 업데이트")
    print("=" * 60)
    
    # 번역된 예문 읽기
    print("\n1. 번역된 예문 읽는 중...")
    translated_examples = read_translated_examples(csv_file)
    
    # 파일 순서 파악
    print("\n2. 파일 순서 파악 중...")
    file_order = read_all_ko_examples_order(txt_file)
    
    # KO 파일들 업데이트
    print("\n3. KO 파일들 업데이트 중...")
    update_ko_files(data_dir, translated_examples, file_order)
    
    print("\n" + "=" * 60)
    print("작업 완료!")
    print("=" * 60)

if __name__ == "__main__":
    main()
