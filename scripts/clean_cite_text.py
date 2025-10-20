#!/usr/bin/env python3
"""
CSV 파일에서 [cite_start]와 [cite: 숫자] 같은 불필요한 텍스트를 제거하는 스크립트
"""

import re
from pathlib import Path

def clean_cite_text(input_file, output_file):
    """
    CSV 파일에서 대괄호 [] 안의 모든 내용을 제거
    
    Args:
        input_file (str): 입력 CSV 파일 경로
        output_file (str): 출력 CSV 파일 경로
    """
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 대괄호 [] 안의 모든 내용을 제거
    cleaned_content = re.sub(r'\[.*?\]', '', content)
    
    # 연속된 공백을 하나로 정리
    cleaned_content = re.sub(r'\s+', ' ', cleaned_content)
    
    # 줄별로 분리하고 빈 줄 제거
    lines = cleaned_content.split('\n')
    cleaned_lines = []
    
    for line in lines:
        line = line.strip()
        if line:  # 빈 줄이 아닌 경우만 추가
            cleaned_lines.append(line + '\n')
    
    # 새로운 파일에 저장
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(cleaned_lines)
    
    print(f"✅ 완료: {input_file} -> {output_file}")
    print(f"총 {len(cleaned_lines)}줄이 정리되었습니다.")

def main():
    """메인 함수"""
    # 파일 경로 설정
    project_root = Path(__file__).parent.parent
    input_file = project_root / "translate_examples.csv"
    output_file = project_root / "translate_examples_cleaned.csv"
    
    if not input_file.exists():
        print(f"❌ 입력 파일을 찾을 수 없습니다: {input_file}")
        return
    
    print(f"입력 파일: {input_file}")
    print(f"출력 파일: {output_file}")
    print("=" * 50)
    
    clean_cite_text(input_file, output_file)
    
    # 원본 파일을 새 파일로 교체
    print("\n원본 파일을 새 파일로 교체합니다...")
    input_file.unlink()  # 원본 파일 삭제
    output_file.rename(input_file)  # 새 파일을 원본 이름으로 변경
    
    print(f"✅ 최종 완료: {input_file}")

if __name__ == "__main__":
    main()
